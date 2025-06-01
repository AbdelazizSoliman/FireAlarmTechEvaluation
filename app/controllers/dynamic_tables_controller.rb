# app/controllers/dynamic_tables_controller.rb
class DynamicTablesController < ApplicationController
  require 'roo'
  require 'did_you_mean'
  require_dependency 'dynamic_table_manager'
  helper_method :filter_params

  # before_action :set_table_name, only: [:add_column]
  # before_action :ensure_subsystem, only: [:upload_excel, :preview_excel, :import_excel_tables, :create_main_tables, :create_child_tables, :create_features, :test_tables]

  # GET /admin
  def admin
    # 1) ALWAYS load these first
    @projects             = Project.all.pluck(:name, :id)
    @project_filter       = params[:project_filter]
    @project_scope_filter = params[:project_scope_filter]
    @system_filter        = params[:system_filter]
    @subsystem_filter     = params[:subsystem_filter]

    # 2) dependent dropdowns
    @project_scopes = if @project_filter.present?
                        Project.find(@project_filter).project_scopes.pluck(:name, :id)
                      else
                        []
                      end

    @systems = if @project_scope_filter.present?
                 ProjectScope.find(@project_scope_filter).systems.pluck(:name, :id)
               else
                 []
               end

    @subsystems = if @system_filter.present?
                    System.find(@system_filter).subsystems.pluck(:name, :id)
                  else
                    []
                  end

    # 3) main vs sub tables for the sidebar
    if @subsystem_filter.present?
      defs         = TableDefinition.where(subsystem_id: @subsystem_filter)
      @main_tables = defs.where(parent_table: nil).order(:position)
      @sub_tables  = defs.where.not(parent_table: nil)
    else
      @main_tables = []
      @sub_tables  = []
    end

    # 4) if they’ve clicked on one of those table links…
    if params[:table_name].present? && ActiveRecord::Base.connection.data_source_exists?(params[:table_name])
      @table_name       = params[:table_name]
      @existing_columns = ActiveRecord::Base
        .connection
        .columns(@table_name)
        .map do |col|
          md = ColumnMetadata.find_by(table_name: @table_name, column_name: col.name)
          { name: col.name, type: col.type, metadata: md }
        end

      # pull the children *here*, outside the map
      @subtables = TableDefinition
        .where(subsystem_id: @subsystem_filter, parent_table: @table_name)
        .order(:position)
    else
      @table_name       = nil
      @existing_columns = []
      @subtables        = []
    end
  end

  # GET /admin/upload_excel
  def upload_excel
    @subsystem_id = params[:subsystem_filter]
  end

  # POST /admin/handle_excel_actions
  def handle_excel_actions
  temp_grid = TempExcelGrid.find_by(session_id: session.id.to_s)
  subsystem_id = session[:subsystem_id]

  unless params[:rows].present?
    flash[:error] = "No selections found. Please assign types to rows."
    redirect_to admin_upload_excel_path(subsystem_filter: subsystem_id) and return
  end

  rows = params[:rows].values

  # Step 1: Create all main tables
  main_tables = rows.select { |r| r["type"] == "main_table" }.map { |r| safe_table_name(r["value"], subsystem_id) }
  params[:table_names] = main_tables
  params[:subsystem_id] = subsystem_id
  create_multiple_tables if main_tables.any?

  # Step 2: Create child tables
  child_rows = rows.select { |r| r["type"] == "child_table" && r["parent"].present? }
  if child_rows.any?
    params[:sub_table_names] = child_rows.map { |r| safe_table_name(r["value"], subsystem_id) }
    params[:parent_tables] = child_rows.map { |r| safe_table_name(r["parent"], subsystem_id) }
    params[:subsystem_id] = subsystem_id
    create_multiple_sub_tables
  end

  # Step 3: Create features
  feature_rows = rows.select { |r| r["type"] == "feature" && r["target"].present? }
  feature_group = feature_rows.group_by { |r| r["target"] }
  feature_group.each do |target_table, feats|
    params[:table_name] = safe_table_name(target_table, subsystem_id)
    params[:feature_names] = feats.map { |f| to_db_name(f["value"]) }
    params[:column_types] = ['string'] * feats.length
    # Save feature type: text (for None), combobox, or checkbox
    params[:features] = feats.map { |f| (f["feature_type"].blank? || f["feature_type"] == "text") ? "text" : f["feature_type"] }
    params[:combobox_values_arr] = [''] * feats.length
    params[:has_costs] = ['0'] * feats.length
    params[:rate_keys] = [''] * feats.length
    params[:amount_keys] = [''] * feats.length
    params[:notes_keys] = [''] * feats.length
    params[:sub_fields] = [''] * feats.length
    params[:array_default_empties] = ['0'] * feats.length

    create_multiple_features
  end

  TempExcelGrid.where(session_id: session.id.to_s).delete_all
  flash[:success] = "All tables and features have been created."
  redirect_to admin_path(subsystem_filter: subsystem_id)
end



  # POST /admin/preview_excel
  def preview_excel
    uploaded = params[:excel_file]
    Rails.logger.info "[PREVIEW] got params[:excel_file]=#{uploaded.inspect}"
    unless uploaded
      flash[:error] = "❗ No file uploaded"
      redirect_to admin_upload_excel_path(subsystem_filter: params[:subsystem_id] || params[:subsystem_filter])
      return
    end

    path = uploaded.tempfile.path
    spreadsheet = Roo::Spreadsheet.open(path)
    sheet = spreadsheet.sheet(0)

    @grid = sheet.each_with_index.map do |row, i|
      row.each_with_index.map do |cell, j|
        { value: cell.to_s, row: i + 1, col: j + 1, selected: false }
      end
    end
    Rails.logger.info "[PREVIEW] Generated grid: #{@grid.inspect}"

    # Store the grid in TempExcelGrid instead of session
    TempExcelGrid.create!(
      session_id: session.id.to_s,
      grid_data: @grid,
      subsystem_id: params[:subsystem_id] || params[:subsystem_filter]
    )
    session[:subsystem_id] = params[:subsystem_id] || params[:subsystem_filter]

    render 'excel_preview', layout: 'application', formats: [:html]
  end

  # POST /admin/submit_preview
  def submit_preview
    Rails.logger.info "[SUBMIT_PREVIEW] Started with params: #{params.inspect}"
    selected_cells = params[:selected_cells] || {}
    temp_grid = TempExcelGrid.find_by(session_id: session.id.to_s)
    unless temp_grid
      flash[:error] = "No preview data found. Please upload the file again."
      redirect_to admin_upload_excel_path(subsystem_filter: session[:subsystem_id])
      return
    end

    grid = temp_grid.grid_data.deep_dup
    selected_cells.each do |key, value|
      # Expect key like "row_1_col_1"
      row, col = key.match(/row_(\d+)_col_(\d+)/)&.captures&.map(&:to_i) || [nil, nil]
      unless row && col
        Rails.logger.error "[SUBMIT_PREVIEW] Invalid key format: #{key}"
        next
      end
      # Ensure the grid indices are within bounds
      if row - 1 < grid.length && col - 1 < grid[row - 1].length
        grid[row - 1][col - 1][:selected] = value == '1'
      else
        Rails.logger.warn "[SUBMIT_PREVIEW] Out of bounds access: row=#{row}, col=#{col}, grid_size=#{grid.length}x#{grid[0].length}"
      end
    end

    temp_grid.update!(grid_data: grid)
    @grid = grid

    Rails.logger.info "[SUBMIT_PREVIEW] Rendering excel_preview with grid: #{@grid.inspect}"
    render 'excel_preview', layout: 'application', formats: [:html]
  end

  # POST /admin/import_excel_tables
  def import_excel_tables
    subsystem_id = params[:subsystem_id] || params[:subsystem_filter]
    if subsystem_id.blank?
      flash[:error] = "No subsystem selected. Please try again."
      redirect_to admin_path
    else
      flash[:notice] = "Please use the preview and selection process to import tables."
      redirect_to admin_upload_excel_path(subsystem_filter: subsystem_id)
    end
  end

  # POST /admin/create_main_tables
 def create_main_tables
  temp_grid = TempExcelGrid.find_by(session_id: session.id.to_s)
  subsystem_id = session[:subsystem_id]
  unless temp_grid
    flash[:error] = "No preview data found. Please upload the file again."
    redirect_to admin_upload_excel_path(subsystem_filter: subsystem_id)
    return
  end

  cell_value = params[:selected_cell_value].to_s.strip

  main_tables = []
  if cell_value.present?
    main_table = safe_table_name(cell_value, subsystem_id)
    main_tables << main_table
  else
    flash[:error] = "Please select a valid main table cell."
    redirect_to admin_upload_excel_path(subsystem_filter: subsystem_id)
    return
  end

  params[:table_names] = main_tables
  params[:subsystem_id] = subsystem_id
  create_multiple_tables

  temp_grid.destroy
  flash[:success] = "Main tables created: #{main_tables.join(', ')}."
  redirect_to admin_path(subsystem_filter: subsystem_id)
end


  # POST /admin/create_child_tables
  def create_child_tables
  temp_grid = TempExcelGrid.find_by(session_id: session.id.to_s)
  subsystem_id = session[:subsystem_id]
  unless temp_grid
    flash[:error] = "No preview data found. Please upload the file again."
    redirect_to admin_upload_excel_path(subsystem_filter: subsystem_id)
    return
  end

  cell_value = params[:selected_cell_value].to_s.strip
  cell_row = params[:selected_cell_row].to_i

  child_tables = []
  # Consider only rows after first row, and must match child pattern (e.g., "1-xxx")
  if cell_value.present? && cell_row > 1 && cell_value.match?(/^\d+-/)
    child_table = to_db_name(cell_value)
    child_tables << child_table
  else
    flash[:error] = "Please select a valid child table cell (must match child pattern in first column, not first row)."
    redirect_to admin_upload_excel_path(subsystem_filter: subsystem_id)
    return
  end

  # For demo, pick parent_table as the main table in the first row, column 1
  parent_table_cell = temp_grid.grid_data[0][0]
  parent_table = parent_table_cell.present? ? to_db_name(parent_table_cell[:value]) : nil

  params[:sub_table_names] = child_tables
  params[:parent_tables] = [parent_table] * child_tables.length
  params[:subsystem_id] = subsystem_id
  create_multiple_sub_tables

  temp_grid.destroy
  flash[:success] = "Child tables created: #{child_tables.join(', ')}."
  redirect_to admin_path(subsystem_filter: subsystem_id)
end

  # POST /admin/create_features
  def create_features
  temp_grid = TempExcelGrid.find_by(session_id: session.id.to_s)
  subsystem_id = session[:subsystem_id]
  unless temp_grid
    flash[:error] = "No preview data found. Please upload the file again."
    redirect_to admin_upload_excel_path(subsystem_filter: subsystem_id)
    return
  end

  cell_value = params[:selected_cell_value].to_s.strip
  cell_row = params[:selected_cell_row].to_i

  features = []
  # For demo, treat any cell in the first column after row 1 as a feature if not a child table (not matching /^\d+-/)
  if cell_value.present? && cell_row > 1 && !cell_value.match?(/^\d+-/)
    feature_name = to_db_name(cell_value)
    features << feature_name
  else
    flash[:error] = "Please select a valid feature cell (first column, after first row, not matching child table pattern)."
    redirect_to admin_upload_excel_path(subsystem_filter: subsystem_id)
    return
  end

  # Get the selected table to add the feature to
  main_table_cell = temp_grid.grid_data[0][0]
  table_name = main_table_cell.present? ? to_db_name(main_table_cell[:value]) : nil

  unless table_name
    flash[:error] = "No main table found to add feature to."
    redirect_to admin_upload_excel_path(subsystem_filter: subsystem_id)
    return
  end

  # The rest is simplified, adjust as needed
  params[:table_name] = table_name
  params[:feature_names] = features
  params[:column_types] = ['string'] * features.length
  params[:features] = [''] * features.length
  params[:combobox_values_arr] = [''] * features.length
  params[:has_costs] = ['0'] * features.length
  params[:rate_keys] = [''] * features.length
  params[:amount_keys] = [''] * features.length
  params[:notes_keys] = [''] * features.length
  params[:sub_fields] = [''] * features.length
  params[:array_default_empties] = ['0'] * features.length

  create_multiple_features

  temp_grid.destroy
  flash[:success] = "Features created for #{table_name}: #{features.join(', ')}."
  redirect_to admin_path(subsystem_filter: subsystem_id)
end

  # GET /admin/test_tables
  def test_tables
    table_name = params[:table_name]
    unless table_name
      flash[:error] = "Please select a table."
      redirect_to admin_path(subsystem_filter: session[:subsystem_id])
      return
    end

    # Basic test: Check if table exists and has columns
    if ActiveRecord::Base.connection.data_source_exists?(table_name)
      columns = ActiveRecord::Base.connection.columns(table_name).map(&:name)
      flash[:success] = "Table #{table_name} exists with columns: #{columns.join(', ')}."
    else
      flash[:error] = "Table #{table_name} does not exist."
    end

    redirect_to admin_path(subsystem_filter: session[:subsystem_id])
  end

  # POST /admin/move_table
  def move_table
    p = params.permit(:direction, :id, :table_name,
                      :project_filter, :project_scope_filter,
                      :system_filter, :subsystem_filter)
    td = TableDefinition.find(p[:id])

    case p[:direction]
    when 'up'
      prev = TableDefinition.where(subsystem_id: td.subsystem_id, parent_table: nil)
                            .where("position < ?", td.position)
                            .order(position: :desc).first
      if prev
        td.position, prev.position = prev.position, td.position
        td.save!
        prev.save!
      end
    when 'down'
      nxt = TableDefinition.where(subsystem_id: td.subsystem_id, parent_table: nil)
                            .where("position > ?", td.position)
                            .order(:position).first
      if nxt
        td.position, nxt.position = nxt.position, td.position
        td.save!
        nxt.save!
      end
    end

    redirect_to admin_path(p.merge(table_name: params[:table_name]))
  end

  # GET /admin/check_table_name
  def check_table_name
    raw    = params[:name].to_s.strip
    tbl    = to_db_name(raw)
    exists = ActiveRecord::Base.connection.data_source_exists?(tbl)
    sugg   = if exists
               "#{tbl}_#{params[:subsystem_name].to_s.parameterize(separator: '_')}"
             else
               get_spelling_suggestion(raw)
             end

    render json: { exists: exists, suggested: sugg }
  end

  # GET /dynamic_tables/:table_name/columns/:column_name/edit_metadata
  def edit_metadata
    @table_name  = params[:table_name]
    @column_name = params[:column_name]
    @metadata    = ColumnMetadata.find_or_initialize_by(
                     table_name:  @table_name,
                     column_name: @column_name
                   )
  end

  # PATCH /dynamic_tables/:table_name/columns/:column_name/update_metadata
  def update_metadata
    @table_name  = params[:table_name]
    @column_name = params[:column_name]
    @metadata    = ColumnMetadata.find_or_initialize_by(
                     table_name:  @table_name,
                     column_name: @column_name
                   )

    if @metadata.update(metadata_params)
      flash[:success] = "Metadata for “#{@column_name}” saved."
      redirect_to admin_path(filter_params.merge(table_name: @table_name))
    else
      flash.now[:error] = @metadata.errors.full_messages.to_sentence
      render :edit_metadata
    end
  end

  # GET /admin/ordered_tables
  def ordered_tables
    subsys = Subsystem.find(params[:subsystem_id])
    mains  = TableDefinition.where(subsystem_id: subsys.id, parent_table: nil)
                            .order(:position)
    render json: mains
  end

  # POST /admin/create_multiple_tables
  def create_multiple_tables
    subsystem_id = params[:subsystem_id].to_i
    raw_names    = Array(params[:table_names])
    duplicates, created = [], []

    Rails.logger.info "[CREATE] Starting bulk-create: #{raw_names.inspect}"

    raw_names.each_with_index do |raw, index|
      tbl = to_db_name(raw)
      Rails.logger.info "[CREATE] Normalized '#{raw}' → '#{tbl}'"
      next if tbl.blank?

      if ActiveRecord::Base.connection.data_source_exists?(tbl)
        Rails.logger.info "[CREATE] Skipping existing #{tbl}"
        duplicates << tbl
      else
        Rails.logger.info "[CREATE] Creating #{tbl}"
        ActiveRecord::Base.connection.create_table(tbl, force: :cascade) do |t|
          t.bigint  :subsystem_id, null: false
          t.bigint  :supplier_id,  null: false
          t.timestamps
          t.index   [:subsystem_id],                         name: "idx_#{tbl}_on_subsystem"
          t.index   [:supplier_id, :subsystem_id], unique: true, name: "idx_#{tbl}_sup_sub"
          t.index   [:supplier_id],                           name: "idx_#{tbl}_on_supplier"
        end

        TableDefinition.create!(
          table_name:   tbl,
          subsystem_id: subsystem_id,
          parent_table: nil,
          position: index + 1 + TableDefinition.where(subsystem_id: subsystem_id, parent_table: nil).maximum(:position).to_i
        )
        created << tbl
      end
    rescue => e
      Rails.logger.error "[CREATE] Error on #{tbl}: #{e.message}"
      flash[:error] ||= ""
      flash[:error] += "Failed #{tbl}: #{e.message}. "
    end

    Rails.logger.info "[CREATE] Done; duplicates=#{duplicates.inspect}, created=#{created.inspect}"

    messages = []
    messages << "Already existed: #{duplicates.join(', ')}." if duplicates.any?
    messages << "Created: #{created.join(', ')}."           if created.any?
    flash[created.any? ? :success : :error] = messages.join(' ')
  end

  # POST /admin/create_multiple_sub_tables
  def create_multiple_sub_tables
    subsystem_id     = params[:subsystem_id]
    raw_names        = params[:sub_table_names] || []
    parents          = params[:parent_tables]   || []
    duplicates, created = [], []

    raw_names.each_with_index do |raw, i|
      tbl    = to_db_name(raw)
      parent = parents[i]
      next if tbl.blank?

      if ActiveRecord::Base.connection.data_source_exists?(tbl)
        duplicates << tbl
      else
        ActiveRecord::Migration.create_table(tbl.to_sym, force: :cascade) do |t|
          t.references :parent, null: false, foreign_key: { to_table: parent }
          t.bigint     :subsystem_id, null: false
          t.bigint     :supplier_id,  null: false
          t.timestamps
          t.index      [:subsystem_id],                            name: "idx_#{tbl}_on_subsystem"
          t.index      [:supplier_id, :subsystem_id], unique: true, name: "idx_#{tbl}_sup_sub"
          t.index      [:supplier_id],                              name: "idx_#{tbl}_on_supplier"
        end
        TableDefinition.create!(
          table_name:   tbl,
          subsystem_id: subsystem_id,
          parent_table: parent
        )
        created << tbl
      end
    rescue => e
      flash[:error] ||= ""
      flash[:error] += "Failed #{tbl}: #{e.message}. "
    end
  end

  # GET /admin/sub_tables
  def sub_tables
    defs = TableDefinition.where(parent_table: params[:parent_table])
    defs = defs.where(subsystem_id: params[:subsystemId]) if params[:subsystemId].present?
    render json: defs.as_json(only: [:id, :table_name, :parent_table])
  end

  # POST /admin/create_multiple_features
  def create_multiple_features
    table_name          = params[:table_name]
    names               = params[:feature_names]       || []
    types               = params[:column_types]        || []
    front_end_features  = params[:features]            || []
    combobox_values_arr = params[:combobox_values_arr] || []
    has_costs           = params[:has_costs]           || []
    rate_keys           = params[:rate_keys]           || []
    amount_keys         = params[:amount_keys]         || []
    notes_keys          = params[:notes_keys]          || []
    sub_fields          = params[:sub_fields]          || []
    array_defaults      = params[:array_default_empties] || []

    created = []

    names.each_with_index do |raw, idx|
      col = to_db_name(raw)
      next unless col.present? && %w[string integer boolean decimal text text[] date].include?(types[idx])

      migration_opts = {}
      col_type       = if types[idx] == 'text[]'
                         migration_opts = { array: true, default: (array_defaults[idx] == '1' ? [] : nil) }
                         :text
                       else
                         types[idx].to_sym
                       end

      ActiveRecord::Migration.add_column(table_name.to_sym, col.to_sym, col_type, **migration_opts)

      md = ColumnMetadata.create!(
        table_name:   table_name,
        column_name:  col,
        feature:      front_end_features[idx].presence,
        has_cost:     has_costs[idx].present?,
        sub_field:    sub_fields[idx],
        rate_key:     rate_keys[idx],
        amount_key:   amount_keys[idx],
        notes_key:    notes_keys[idx],
        options:      begin
                        vals = combobox_values_arr[idx].to_s.split(',').map(&:strip)
                        vals.any? ? { allowed_values: vals } : {}
                      end
      )

      created << col
    rescue => e
      flash[:error] ||= ""
      flash[:error] += "Failed feature #{col}: #{e.message}. "
    end
  end

  # GET /admin/feature_row
  def feature_row
    render partial: 'feature_row', locals: { idx: params[:idx].to_i }
  end

  # POST /admin/add_column
  def add_column
    tbl  = params[:table_name]
    raw  = params[:column_name]
    col  = to_db_name(raw)
    type = params[:column_type]
    feat = params[:feature]
    vals = params[:feature_values].to_s.split(',').map(&:strip).reject(&:blank?)

    ::DynamicTableManager.add_column(tbl, col, type)

    md = ColumnMetadata.find_or_initialize_by(table_name: tbl, column_name: col)
    md.feature   = feat
    md.row       = params[:row]
    md.col       = params[:col]
    md.label_row = params[:label_row]
    md.label_col = params[:label_col]
    md.options   ||= {}
    md.options['allowed_values'] = vals
    md.save!

    flash[:success] = "Column #{col} added to #{tbl}."
    redirect_to admin_path(table_name: tbl, **filter_params)
  end

  # GET /dynamic_tables/:table_name
  def show
    subsys = params[:subsystemId]
    tbl    = params[:table_name]
    td     = TableDefinition.find_by(table_name: tbl)

    unless td
      render json: { error: "Invalid table" }, status: :bad_request
      return
    end

    model   = tbl.classify.constantize
    records = model.where(subsystem_id: subsys)
    render json: {
      columns: records.first&.attributes&.keys,
      data:    records,
      static:  td.static?
    }
  rescue NameError
    render json: { error: "Invalid table" }, status: :bad_request
  end

  private

  # Convert A1 style ref like "B3" → [3, 2]
  def parse_a1_ref(ref)
    col_letters = ref[/[A-Z]+/]
    row_number  = ref[/\d+/].to_i
    col_number  = col_letters.chars.reduce(0) { |sum, ch|
      sum * 26 + (ch.ord - 'A'.ord + 1)
    }
    [row_number, col_number]
  end

 def to_db_name(name)
  normalized = name.to_s.parameterize(separator: '_').gsub(/__+/, '_').gsub(/^_+|_+$/, '')
  normalized = "table_#{normalized}" if normalized.match?(/\A\d/)
  normalized
end


  def metadata_params
    params.require(:column_metadata).permit(
      :feature,
      :has_cost,
      :standard_value,
      :tolerance,
      :sub_field,
      :rate_key,
      :amount_key,
      :notes_key,
      options: [:allowed_values, :mandatory_values, combo_standards: {}]
    )
  end

  def filter_params
    params.slice(
      :project_filter,
      :project_scope_filter,
      :system_filter,
      :subsystem_filter
    ).permit!
  end

  def set_table_name
    @table_name = params[:table_name]
    unless @table_name.present? && ActiveRecord::Base.connection.data_source_exists?(@table_name)
      flash[:error] = "Table #{@table_name} does not exist!"
      redirect_to admin_path and return
    end
  end

  def ensure_subsystem
    @subsystem_filter = params[:subsystem_filter].presence || params[:subsystem_id].presence || session[:subsystem_id]
    unless @subsystem_filter.present?
      flash[:error] = "Please select a subsystem first."
      redirect_to admin_path and return
    end
  end

  def get_spelling_suggestion(word)
    dict = %w[fire alarm panel pump system smoke bell sprinkler switch wiring detector access lighting power control emergency network security]
    distances = dict.map { |w| [w, levenshtein_distance(word.downcase, w)] }
    best = distances.min_by(&:last)
    best[0] if best && best[1] <= 2
  end

  def levenshtein_distance(a, b)
    (Array.new(a.length + 1) { |i| i }).tap do |m|
      (1..b.length).each { |j| m[0, j] = j }
      (1..a.length).each do |i|
        (1..b.length).each do |j|
          cost = a[i - 1] == b[j - 1] ? 0 : 1
          m[i, j] = [m[i - 1, j] + 1, m[i, j - 1] + 1, m[i - 1, j - 1] + cost].min
        end
      end
    end[a.length, b.length]
  end

  def infer_feature_details(feature_name, raw_value)
    feature_name = feature_name.downcase
    allowed_values = raw_value.present? ? raw_value.split(',').map(&:strip) : []

    # Infer column type
    col_type = if feature_name.match?(/total no\.|number of/i)
                 'integer'
               elsif feature_name.match?(/antibacterial|waterproof|led indicator/i)
                 'boolean'
               else
                 'string'
               end

    # Infer frontend feature based on raw_value format
    frontend_feature = if raw_value.present?
                         if raw_value.downcase.start_with?('combobox:')
                           allowed_values = raw_value.sub(/^combobox:/i, '').split(',').map(&:strip)
                           'combobox'
                         elsif raw_value.downcase.start_with?('checkbox:')
                           allowed_values = raw_value.sub(/^checkbox:/i, '').split(',').map(&:strip)
                           'checkboxes'
                         elsif allowed_values.length > 1
                           'combobox'
                         elsif allowed_values.length == 1 && col_type == 'boolean'
                           'checkbox'
                         else
                           ''
                         end
                       else
                         col_type == 'boolean' ? 'checkbox' : ''
                       end

    [col_type, frontend_feature, allowed_values]
  end

def safe_table_name(base_name, subsystem_id)
  name = to_db_name(base_name)
  if ActiveRecord::Base.connection.data_source_exists?(name)
    subsystem = Subsystem.find(subsystem_id)
    name = "#{name}_#{to_db_name(subsystem.name)}"
  end
  name
end


end