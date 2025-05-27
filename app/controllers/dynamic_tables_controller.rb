# app/controllers/dynamic_tables_controller.rb
class DynamicTablesController < ApplicationController
  require 'roo'
  require 'did_you_mean'
  require_dependency 'dynamic_table_manager'
  helper_method :filter_params

  before_action :set_table_name,   only: [:add_column]
  before_action :ensure_subsystem, only: [:upload_excel, :preview_excel, :import_excel_tables]

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
    if params[:table_name].present? &&
       ActiveRecord::Base.connection.data_source_exists?(params[:table_name])

      @table_name       = params[:table_name]
      @existing_columns =
        ActiveRecord::Base
          .connection
          .columns(@table_name)
          .map do |col|
            md = ColumnMetadata.find_by(
                   table_name:  @table_name,
                   column_name: col.name
                 )
            { name: col.name, type: col.type, metadata: md }
          end

      # pull the children *here*, outside the map
      @subtables =
        TableDefinition
          .where(
            subsystem_id: @subsystem_filter,
            parent_table: @table_name
          )
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

  # POST /admin/preview_excel
  def preview_excel
    uploaded = params[:excel_file]
    Rails.logger.info "[PREVIEW] got params[:excel_file]=#{uploaded.inspect}"
    unless uploaded
      render plain: "❗ No file uploaded", status: :bad_request
      return
    end

    path        = uploaded.tempfile.path
    spreadsheet = Roo::Spreadsheet.open(path)
    sheet       = spreadsheet.sheet(0)

    @grid = sheet.each_with_index.map do |row, i|
      row.each_with_index.map do |cell, j|
        { value: cell.to_s, row: i + 1, col: j + 1 }
      end
    end

    render partial: 'excel_preview'
  end

 # POST /admin/import_excel_tables
def import_excel_tables
  uploaded  = params[:excel_file]
  subsystem = params[:subsystem_id] || params[:subsystem_filter]

  unless uploaded
    flash[:error] = "No file uploaded!"
    return redirect_to admin_upload_excel_path(subsystem_filter: subsystem)
  end

  sheet = Roo::Spreadsheet.open(uploaded.tempfile.path).sheet(0)
  rows = sheet.parse # Convert sheet to an array of rows

  # Step 1: Parse the Excel structure
  main_table = nil
  current_subtable = nil
  subtables = {} # { subtable_name => { parent: main_table, features: [{name, type, frontend_feature, values}] } }

  rows.each_with_index do |row, idx|
    next if row.compact.empty? # Skip empty rows

    cell = row[0].to_s.strip
    next if cell.empty?

    # Main table (red cell, assumed to be the first non-empty cell in column A)
    if main_table.nil?
      main_table = to_db_name(cell)
      next
    end

    # Subtable detection (e.g., "1-Call-reset-button", "2-Pull-cord")
    if cell.match?(/^\d+-/)
      subtable_name = to_db_name(cell)
      current_subtable = subtable_name
      subtables[current_subtable] = { parent: main_table, features: [] }
      next
    end

    # Features under the current subtable
    if current_subtable
      feature_name = to_db_name(cell)
      # Right side might contain type/values in the future (column B)
      raw_value = row[1].to_s.strip if row[1]

      # Infer column type and frontend feature
      col_type, frontend_feature, allowed_values = infer_feature_details(cell, raw_value)

      subtables[current_subtable][:features] << {
        name: feature_name,
        type: col_type,
        frontend_feature: frontend_feature,
        values: allowed_values
      }
    end
  end

  # Step 2: Create the main table
  params[:table_names] = [main_table]
  params[:subsystem_id] = subsystem
  create_multiple_tables

  # Step 3: Create subtables and their features
  subtables.each do |subtable_name, data|
    # Create the subtable
    params[:sub_table_names] = [subtable_name]
    params[:parent_tables] = [data[:parent]]
    params[:subsystem_id] = subsystem
    create_multiple_sub_tables

    # Create features for the subtable
    unless data[:features].empty?
      feature_names = []
      column_types = []
      front_end_features = []
      combobox_values_arr = []
      has_costs = []
      rate_keys = []
      amount_keys = []
      notes_keys = []
      sub_fields = []
      array_defaults = []

      data[:features].each do |feature|
        feature_names << feature[:name]
        column_types << feature[:type]
        front_end_features << feature[:frontend_feature]
        combobox_values_arr << (feature[:values] || []).join(',')
        # Default values for other fields (can be enhanced later)
        has_costs << '0'
        rate_keys << ''
        amount_keys << ''
        notes_keys << ''
        sub_fields << ''
        array_defaults << '0'
      end

      params[:table_name] = subtable_name
      params[:feature_names] = feature_names
      params[:column_types] = column_types
      params[:features] = front_end_features
      params[:combobox_values_arr] = combobox_values_arr
      params[:has_costs] = has_costs
      params[:rate_keys] = rate_keys
      params[:amount_keys] = amount_keys
      params[:notes_keys] = notes_keys
      params[:sub_fields] = sub_fields
      params[:array_default_empties] = array_defaults

      create_multiple_features
    end
  end

  flash[:success] = "Imported tables, subtables, and features from Excel."
  redirect_to admin_path(subsystem_filter: subsystem)
end

  # POST /admin/move_table
  def move_table
    p  = params.permit(:direction, :id, :table_name,
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
        td.save!; prev.save!
      end
    when 'down'
      nxt = TableDefinition.where(subsystem_id: td.subsystem_id, parent_table: nil)
                            .where("position > ?", td.position)
                            .order(:position).first
      if nxt
        td.position, nxt.position = nxt.position, td.position
        td.save!; nxt.save!
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

    raw_names.each do |raw|
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
          parent_table: nil
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
    flash[ created.any? ? :success : :error ] = messages.join(' ')
    redirect_to admin_path(subsystem_filter: subsystem_id)
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

    msg = []
    msg << "Already exist: #{duplicates.join(', ')}." if duplicates.any?
    msg << "Created: #{created.join(', ')}."               if created.any?
    flash[created.empty? ? :error : :success] = msg.join(' ')
    redirect_to admin_path(filter_params)
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
    array_defaults      = params[:array_default_empties]|| []

    created = []

    names.each_with_index do |raw, idx|
      col = to_db_name(raw)
      next unless col.present? && %w[string integer boolean decimal text text[] date].include?(types[idx])

      migration_opts = {}
      col_type       = if types[idx] == 'text[]'
                         migration_opts = { array: true, default: (array_defaults[idx]=='1' ? [] : nil) }
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

    if created.any?
      flash[:success] = "Features created: #{created.join(', ')}."
    elsif flash[:error].blank?
      flash[:error] = "No features created."
    end

    redirect_to admin_path(table_name: table_name, **filter_params)
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
    name.to_s.parameterize(separator: '_').gsub(/__+/, '_').gsub(/^_+|_+$/, '')
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
    unless @table_name.present? &&
           ActiveRecord::Base.connection.data_source_exists?(@table_name)
      flash[:error] = "Table #{@table_name} does not exist!"
      redirect_to admin_path and return
    end
  end

  def ensure_subsystem
    @subsystem_filter = params[:subsystem_filter].presence || params[:subsystem_id].presence
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
    (Array.new(a.length+1) { |i| i }).tap do |m|
      (1..b.length).each { |j| m[0, j] = j }
      (1..a.length).each do |i|
        (1..b.length).each do |j|
          cost = a[i-1] == b[j-1] ? 0 : 1
          m[i, j] = [m[i-1, j] + 1, m[i, j-1] + 1, m[i-1, j-1] + cost].min
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
end
