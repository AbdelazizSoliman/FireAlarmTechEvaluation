# app/controllers/dynamic_tables_controller.rb
class DynamicTablesController < ApplicationController
  require 'did_you_mean'
  require_dependency 'dynamic_table_manager'
  helper_method :filter_params

  before_action :set_table_name, only: [:add_column]

  # GET /admin
  def admin
    @projects               = Project.all.pluck(:name, :id)
    @project_filter         = params[:project_filter]
    @project_scope_filter   = params[:project_scope_filter]
    @system_filter          = params[:system_filter]
    @subsystem_filter       = params[:subsystem_filter]

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

    if @subsystem_filter.present?
      table_defs    = TableDefinition.where(subsystem_id: @subsystem_filter)
      @main_tables  = table_defs.where(parent_table: nil).order(:position)
      @sub_tables   = table_defs.where.not(parent_table: nil)
    else
      @main_tables = []
      @sub_tables  = []
    end

    if params[:table_name].present? && ActiveRecord::Base.connection.table_exists?(params[:table_name])
      @table_name      = params[:table_name]
      @existing_columns = ActiveRecord::Base.connection.columns(@table_name).map do |col|
        md = ColumnMetadata.find_by(table_name: @table_name, column_name: col.name)
        { name: col.name, type: col.type, metadata: md }
      end
    else
      @table_name       = nil
      @existing_columns = []
    end
  end

  # POST /admin/move_table
  def move_table
    p = params.permit(:direction, :id, :table_name, :project_filter,
                      :project_scope_filter, :system_filter, :subsystem_filter)
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

  # GET  /admin/check_table_name
  def check_table_name
    raw    = params[:name].to_s.strip
    tbl    = to_db_name(raw)
    exists = ActiveRecord::Base.connection.table_exists?(tbl)
    sugg   = if exists
               "#{tbl}_#{params[:subsystem_name].to_s.parameterize(separator: '_')}"
             else
               get_spelling_suggestion(raw)
             end

    render json: {
      exists: exists,
      suggested: sugg
    }
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
    subsys     = Subsystem.find(params[:subsystem_id])
    mains      = TableDefinition.where(subsystem_id: subsys.id, parent_table: nil)
                                 .order(:position)
    render json: mains
  end

  # POST /admin/create_multiple_tables
  def create_multiple_tables
    subsystem_id       = params[:subsystem_id]
    raw_names          = params[:table_names] || []
    duplicates, created = [], []

    raw_names.each do |raw|
      tbl = to_db_name(raw)
      next if tbl.blank?
      if ActiveRecord::Base.connection.table_exists?(tbl)
        duplicates << tbl
      else
        ActiveRecord::Migration.create_table(tbl.to_sym, force: :cascade) do |t|
          t.bigint :subsystem_id, null: false
          t.bigint :supplier_id,  null: false
          t.timestamps
          t.index [:subsystem_id],                                name: "idx_#{tbl}_on_subsystem"
          t.index [:supplier_id, :subsystem_id], unique: true,     name: "idx_#{tbl}_sup_sub"
          t.index [:supplier_id],                                  name: "idx_#{tbl}_on_supplier"
        end
        TableDefinition.create!(table_name: tbl,
                                subsystem_id: subsystem_id,
                                parent_table: nil)
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
      if ActiveRecord::Base.connection.table_exists?(tbl)
        duplicates << tbl
      else
        ActiveRecord::Migration.create_table(tbl.to_sym, force: :cascade) do |t|
          t.references :parent, null: false, foreign_key: { to_table: parent }
          t.bigint :subsystem_id, null: false
          t.bigint :supplier_id,  null: false
          t.timestamps
          t.index [:subsystem_id],                              name: "idx_#{tbl}_on_subsystem"
          t.index [:supplier_id, :subsystem_id], unique: true,   name: "idx_#{tbl}_sup_sub"
          t.index [:supplier_id],                                name: "idx_#{tbl}_on_supplier"
        end
        TableDefinition.create!(table_name: tbl,
                                subsystem_id: subsystem_id,
                                parent_table: parent)
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
    names               = params[:feature_names]        || []
    types               = params[:column_types]         || []
    front_end_features  = params[:features]             || []
    combobox_values_arr = params[:combobox_values_arr]  || []
    has_costs           = params[:has_costs]            || []
    rate_keys           = params[:rate_keys]            || []
    amount_keys         = params[:amount_keys]          || []
    notes_keys          = params[:notes_keys]           || []
    sub_fields          = params[:sub_fields]           || []
    array_defaults      = params[:array_default_empties]|| []

    created = []

    names.each_with_index do |raw, idx|
      col = to_db_name(raw)
      next unless col.present? && %w[string integer boolean decimal text text[] date].include?(types[idx])

      migration_opts = {}
      col_type       = if types[idx] == 'text[]'
                         migration_opts = { array: true, default: (array_defaults[idx]=='1'?[]:nil) }
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
    md.feature      = feat
    md.row          = params[:row]
    md.col          = params[:col]
    md.label_row    = params[:label_row]
    md.label_col    = params[:label_col]
    md.options      ||= {}
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
      return render json: { error: "Invalid table" }, status: :bad_request
    end

    model = tbl.classify.constantize
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
      options: [:allowed_values]
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
    unless @table_name.present? && ActiveRecord::Base.connection.table_exists?(@table_name)
      flash[:error] = "Table #{@table_name} does not exist!"
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
    (Array.new(a.length+1){|i|i}).tap do |m|
      (1..b.length).each{|j| m[0,j]=j }
      (1..a.length).each do |i|
        (1..b.length).each do |j|
          cost = a[i-1]==b[j-1] ? 0 : 1
          m[i,j] = [m[i-1,j]+1, m[i,j-1]+1, m[i-1,j-1]+cost].min
        end
      end
    end[a.length, b.length]
  end

  def to_db_name(name)
    name.to_s
        .parameterize(separator: '_')
        .gsub(/__+/, '_')
        .gsub(/^_+|_+$/, '')
  end
end
