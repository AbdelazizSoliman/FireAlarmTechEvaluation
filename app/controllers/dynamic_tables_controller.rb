class DynamicTablesController < ApplicationController
  require 'did_you_mean'

  before_action :set_table_name, only: [:add_column]

  def admin
    @projects = Project.all.pluck(:name, :id)
    @project_filter = params[:project_filter]
    @project_scope_filter = params[:project_scope_filter]
    @system_filter = params[:system_filter]
    @subsystem_filter = params[:subsystem_filter]

    @project_scopes = @project_filter.present? ? Project.find(@project_filter).project_scopes.pluck(:name, :id) : []
    @systems = @project_scope_filter.present? ? ProjectScope.find(@project_scope_filter).systems.pluck(:name, :id) : []
    @subsystems = @system_filter.present? ? System.find(@system_filter).subsystems.pluck(:name, :id) : []

    if @subsystem_filter.present?
      table_defs = TableDefinition.where(subsystem_id: @subsystem_filter)
      @main_tables = table_defs.where(parent_table: nil).order(:position)
      @sub_tables = table_defs.where.not(parent_table: nil)
    else
      @main_tables = []
      @sub_tables = []
    end

    if params[:table_name].present? && ActiveRecord::Base.connection.table_exists?(params[:table_name])
      @table_name = params[:table_name]
      @existing_columns = ActiveRecord::Base.connection.columns(@table_name).map do |col|
        metadata = ColumnMetadata.find_by(table_name: @table_name, column_name: col.name)
        { name: col.name, type: col.type, metadata: metadata }
      end
    else
      @table_name = nil
      @existing_columns = []
    end
  end

  def move_table
    permitted_params = params.permit(:direction, :id, :table_name, :project_filter, :project_scope_filter, :system_filter, :subsystem_filter)
    table_def = TableDefinition.find(permitted_params[:id])
    direction = permitted_params[:direction]

    if direction == 'up'
      prev_table = TableDefinition.where(subsystem_id: table_def.subsystem_id, parent_table: nil)
                                   .where("position < ?", table_def.position)
                                   .order(position: :desc).first
      if prev_table
        table_def.position, prev_table.position = prev_table.position, table_def.position
        table_def.save!
        prev_table.save!
      end
    elsif direction == 'down'
      next_table = TableDefinition.where(subsystem_id: table_def.subsystem_id, parent_table: nil)
                                   .where("position > ?", table_def.position)
                                   .order(:position).first
      if next_table
        table_def.position, next_table.position = next_table.position, table_def.position
        table_def.save!
        next_table.save!
      end
    end

    redirect_to admin_path(filter_params.merge(table_name: params[:table_name]))
  end

  def check_table_name
    raw_name = params[:name].to_s.strip
    table_name = to_db_name(raw_name)
    exists = ActiveRecord::Base.connection.table_exists?(table_name)
    suggestion = get_spelling_suggestion(raw_name)
    suggested_name = exists ? "#{table_name}_#{params[:subsystem_name].to_s.parameterize(separator: '_')}" : nil

    render json: {
      exists: exists,
      suggested: suggested_name,
      spelling_suggestion: suggestion
    }
  end

  def get_spelling_suggestion(word)
    dictionary = %w[fire alarm panel pump system smoke bell sprinkler switch wiring detector access lighting power control emergency network security]
    distances = dictionary.map { |dict_word| [dict_word, levenshtein_distance(word.downcase, dict_word)] }
    best_match = distances.min_by(&:last)
    return best_match[0] if best_match && best_match[1] <= 2
    nil
  end

  def levenshtein_distance(a, b)
    a_len, b_len = a.length, b.length
    return b_len if a_len.zero?
    return a_len if b_len.zero?
    matrix = Array.new(a_len + 1) { Array.new(b_len + 1) }
    (0..a_len).each { |i| matrix[i][0] = i }
    (0..b_len).each { |j| matrix[0][j] = j }
    (1..a_len).each do |i|
      (1..b_len).each do |j|
        cost = a[i - 1] == b[j - 1] ? 0 : 1
        matrix[i][j] = [matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost].min
      end
    end
    matrix[a_len][b_len]
  end

  def ordered_tables
    subsystem = Subsystem.find(params[:subsystem_id])
    main_tables = TableDefinition.where(subsystem_id: subsystem.id, parent_table: nil).order(:position)
    render json: main_tables
  end

  def create_multiple_tables
    subsystem_id = params[:subsystem_id]
    raw_table_names = params[:table_names] || []
    duplicate_tables = []
    created_tables = []

    raw_table_names.each do |raw_name|
      table_name = to_db_name(raw_name)
      next if table_name.blank?

      if ActiveRecord::Base.connection.table_exists?(table_name)
        duplicate_tables << table_name
        next
      end

      begin
        ActiveRecord::Migration.create_table(table_name.to_sym, force: :cascade) do |t|
          t.bigint :subsystem_id, null: false
          t.bigint :supplier_id, null: false
          t.timestamps
          t.index [:subsystem_id], name: "index_#{table_name}_on_subsystem_id"
          t.index [:supplier_id, :subsystem_id], name: "idx_#{table_name}_sup_sub", unique: true
          t.index [:supplier_id], name: "index_#{table_name}_on_supplier_id"
        end

        TableDefinition.create!(table_name: table_name, subsystem_id: subsystem_id, parent_table: nil)
        created_tables << table_name
      rescue => e
        Rails.logger.error "❌ Error creating table #{table_name}: #{e.message}"
        flash[:error] ||= ""
        flash[:error] += "Failed to create #{table_name}: #{e.message}. "
      end
    end

    msg = ""
    msg += "Tables already exist: #{duplicate_tables.join(', ')}. " if duplicate_tables.any?
    msg += "Created tables: #{created_tables.join(', ')} successfully." if created_tables.any?
    flash[created_tables.empty? ? :error : :success] = msg
    redirect_to admin_path(filter_params)
  end

  def create_multiple_sub_tables
    subsystem_id = params[:subsystem_id]
    raw_sub_table_names = params[:sub_table_names] || []
    parent_tables = params[:parent_tables] || []
    duplicate_tables = []
    created_sub_tables = []

    raw_sub_table_names.each_with_index do |raw_name, idx|
      sub_table_name = to_db_name(raw_name)
      parent_table = parent_tables[idx]
      next if sub_table_name.blank?
      if ActiveRecord::Base.connection.table_exists?(sub_table_name)
        duplicate_tables << sub_table_name
        next
      end

      begin
        ActiveRecord::Migration.create_table(sub_table_name.to_sym, force: :cascade) do |t|
          t.references :parent, null: false, foreign_key: { to_table: parent_table }
          t.bigint :subsystem_id, null: false
          t.bigint :supplier_id, null: false
          t.timestamps
          t.index [:subsystem_id], name: "index_#{sub_table_name}_on_subsystem_id"
          t.index [:supplier_id, :subsystem_id], name: "idx_#{sub_table_name}_sup_sub", unique: true
          t.index [:supplier_id], name: "index_#{sub_table_name}_on_supplier_id"
        end

        TableDefinition.create!(table_name: sub_table_name, subsystem_id: subsystem_id, parent_table: parent_table)
        created_sub_tables << sub_table_name
      rescue => e
        Rails.logger.error "❌ Error creating sub-table #{sub_table_name}: #{e.message}"
        flash[:error] ||= ""
        flash[:error] += "Failed to create #{sub_table_name}: #{e.message}. "
      end
    end

    msg = ""
    msg += "Sub Tables already exist: #{duplicate_tables.join(', ')}. " if duplicate_tables.any?
    msg += "Created sub tables: #{created_sub_tables.join(', ')} successfully." if created_sub_tables.any?
    flash[created_sub_tables.empty? ? :error : :success] = msg
    redirect_to admin_path(filter_params)
  end

  def sub_tables
    parent_table = params[:parent_table]
    subsystem_id = params[:subsystemId]
  
    sub_defs = TableDefinition.where(parent_table: parent_table)
    sub_defs = sub_defs.where(subsystem_id: subsystem_id) if subsystem_id.present?
  
    render json: sub_defs.as_json(only: [:id, :table_name, :parent_table])
  end
  

  def create_multiple_features
    table_name = params[:table_name]
    feature_names        = params[:feature_names]        || []
    column_types         = params[:column_types]         || []
    features             = params[:features]             || []
    combobox_values_arr  = params[:combobox_values_arr]  || []
    has_sub_options_arr  = params[:has_sub_options_arr]  || []
    has_costs            = params[:has_costs]            || []
    rate_keys            = params[:rate_keys]            || []
    amount_keys          = params[:amount_keys]          || []
    notes_keys           = params[:notes_keys]           || []
    sub_fields           = params[:sub_fields]           || []
    array_default_empties = params[:array_default_empties] || []
  
    created_features = []
  
    feature_names.each_with_index do |raw_name, idx|
      col_name = to_db_name(raw_name)
      next if col_name.blank?
  
      col_type = column_types[idx]
      front_feature = features[idx]
      allowed_types = %w[string integer boolean decimal text text[] date]
      next unless allowed_types.include?(col_type)
  
      begin
        ActiveRecord::Migration.add_column(
          table_name.to_sym,
          col_name.to_sym,
          col_type == 'text[]' ? :text : col_type.to_sym,
          (col_type == 'text[]' ? { array: true, default: (array_default_empties[idx] == '1' ? [] : nil) } : {})
        )
  
        raw_values = combobox_values_arr[idx].presence
        parsed_values = raw_values ? raw_values.split(',').map(&:strip) : nil
  
        options_hash = {}
        options_hash[:values] = parsed_values if parsed_values
  
        ColumnMetadata.create!(
          table_name: table_name,
          column_name: col_name,
          feature: front_feature,
          has_cost: has_costs[idx].present?,
          sub_field: sub_fields[idx],
          rate_key: rate_keys[idx],
          amount_key: amount_keys[idx],
          notes_key: notes_keys[idx],
          options: options_hash
        )
  
        created_features << col_name
      rescue => e
        Rails.logger.error "❌ Error adding column #{col_name}: #{e.message}"
        flash[:error] ||= ""
        flash[:error] += "Error adding #{col_name}: #{e.message}. "
      end
    end
  
    msg = created_features.any? ? "Created features: #{created_features.join(', ')}" : "No features created."
    flash[created_features.any? ? :success : :error] = msg
    redirect_to admin_path(table_name: table_name, **filter_params)
  end
  
  def add_column
    table_name = params[:table_name]
    column_name = params[:column_name]
    column_type = params[:column_type]
    feature = params[:feature]
    allowed_values = params[:feature_values].to_s.split(',').map(&:strip).reject(&:blank?).uniq

    DynamicTableManager.add_column(table_name, column_name, column_type)

    metadata = ColumnMetadata.find_or_initialize_by(table_name: table_name, column_name: column_name)
    metadata.feature = feature
    metadata.options = metadata.options.merge("allowed_values" => allowed_values)
    metadata.save!

    flash[:success] = "Column #{column_name} added to #{table_name}."
    redirect_to admin_path(table_name: table_name, **filter_params)
  end

  def show
    subsystem_id = params[:subsystemId]
    table_name = params[:table_name]
    allowed_tables = TableDefinition.pluck(:table_name) # Dynamically allow all created tables
    unless allowed_tables.include?(table_name)
      return render json: { error: "Invalid table" }, status: :bad_request
    end

    model = table_name.classify.constantize
    records = model.where(subsystem_id: subsystem_id)

    render json: {
      columns: records.first&.attributes&.keys,
      data: records
    }
  rescue NameError
    render json: { error: "Invalid table" }, status: :bad_request
  end

  private

  def filter_params
    params.permit(:project_filter, :project_scope_filter, :system_filter, :subsystem_filter)
  end

  def set_table_name
    @table_name = params[:table_name]
    unless @table_name.present? && ActiveRecord::Base.connection.table_exists?(@table_name)
      flash[:error] = "Table #{@table_name} does not exist!"
      redirect_to admin_path and return
    end
  end

  def to_db_name(name)
    name.to_s
        .parameterize(separator: '_') # handles spaces, camelCase, PascalCase, symbols, etc.
        .gsub(/__+/, '_')             # collapse double underscores
        .gsub(/^_+|_+$/, '')          # remove leading/trailing
  end
  
end
