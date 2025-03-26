class DynamicTablesController < ApplicationController
  before_action :set_table_name, only: [:add_column]

  def admin
    # --- Filters: Project, Discipline (Scope), System, and Subsystem ---
    @projects = Project.all.pluck(:name, :id)
    @project_filter      = params[:project_filter]
    @project_scope_filter = params[:project_scope_filter]
    @system_filter       = params[:system_filter]
    @subsystem_filter    = params[:subsystem_filter]

    @project_scopes = @project_filter.present? ? Project.find(@project_filter).project_scopes.pluck(:name, :id) : []
    @systems        = @project_scope_filter.present? ? ProjectScope.find(@project_scope_filter).systems.pluck(:name, :id) : []
    @subsystems     = @system_filter.present? ? System.find(@system_filter).subsystems.pluck(:name, :id) : []

    # --- Load table definitions if a subsystem is selected ---
    if @subsystem_filter.present?
      table_defs = TableDefinition.where(subsystem_id: @subsystem_filter)
      @main_tables = table_defs.where(parent_table: nil)
      @sub_tables  = table_defs.where.not(parent_table: nil)
    else
      @main_tables = []
      @sub_tables  = []
    end

    # --- Load selected table’s columns (with metadata) ---
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

  # === Create Multiple Main Tables (as before) ===
  def create_multiple_tables
    subsystem_id = params[:subsystem_id]
    raw_table_names = params[:table_names] || []
    duplicate_tables = []
    created_tables   = []
    
    raw_table_names.each_with_index do |raw_name, idx|
      table_name = to_db_name(raw_name)
      next if table_name.blank?
      if ActiveRecord::Base.connection.table_exists?(table_name)
        duplicate_tables << table_name
        next
      end
      timestamp = (Time.now + idx).strftime('%Y%m%d%H%M%S')
      migration_name = "Create#{table_name.camelcase}"
      migration_file = Rails.root.join("db/migrate/#{timestamp}_#{migration_name.underscore}.rb")
      migration_content = <<-RUBY
        class #{migration_name} < ActiveRecord::Migration[7.1]
          def change
            create_table :#{table_name}, force: :cascade do |t|
              t.bigint :subsystem_id, null: false
              t.bigint :supplier_id, null: false
              t.timestamps
              t.index [:subsystem_id], name: "index_#{table_name}_on_subsystem_id"
              t.index [:supplier_id, :subsystem_id], name: "idx_#{table_name}_sup_sub", unique: true
              t.index [:supplier_id], name: "index_#{table_name}_on_supplier_id"
            end
          end
        end
      RUBY
      File.write(migration_file, migration_content)
      system('rails db:migrate')
      TableDefinition.create!(table_name: table_name, subsystem_id: subsystem_id, parent_table: nil)
      created_tables << table_name
    end

    msg = ""
    msg += "Tables already exist: #{duplicate_tables.join(', ')}. " if duplicate_tables.any?
    msg += "Created tables: #{created_tables.join(', ')} successfully." if created_tables.any?
    flash[created_tables.empty? ? :error : :success] = msg
    redirect_to admin_path(filter_params)
  end

  # === Create Multiple Sub Tables ===
  # Expect arrays: sub_table_names[] and parent_tables[] (each row with a sub-table name and its parent)
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
      timestamp = (Time.now + idx).strftime('%Y%m%d%H%M%S')
      migration_name = "Create#{sub_table_name.camelcase}"
      migration_file = Rails.root.join("db/migrate/#{timestamp}_#{migration_name.underscore}.rb")
      migration_content = <<-RUBY
        class #{migration_name} < ActiveRecord::Migration[7.1]
          def change
            create_table :#{sub_table_name}, force: :cascade do |t|
              t.references :parent, null: false, foreign_key: { to_table: :#{parent_table} }
              t.bigint :subsystem_id, null: false
              t.bigint :supplier_id, null: false
              t.timestamps
              t.index [:subsystem_id], name: "index_#{sub_table_name}_on_subsystem_id"
              t.index [:supplier_id, :subsystem_id], name: "idx_#{sub_table_name}_sup_sub", unique: true
              t.index [:supplier_id], name: "index_#{sub_table_name}_on_supplier_id"
            end
          end
        end
      RUBY
      File.write(migration_file, migration_content)
      system('rails db:migrate')
      TableDefinition.create!(table_name: sub_table_name, subsystem_id: subsystem_id, parent_table: parent_table)
      created_sub_tables << sub_table_name
    end

    msg = ""
    msg += "Sub Tables already exist: #{duplicate_tables.join(', ')}. " if duplicate_tables.any?
    msg += "Created sub tables: #{created_sub_tables.join(', ')} successfully." if created_sub_tables.any?
    flash[created_sub_tables.empty? ? :error : :success] = msg
    redirect_to admin_path(filter_params)
    Rails.logger.debug "Sub table names: #{raw_sub_table_names.inspect}"
Rails.logger.debug "Parent tables: #{parent_tables.inspect}"

  end

  def sub_tables
    parent_table = params[:parent_table]
    # Find all TableDefinition records whose parent_table == the chosen main table
    sub_defs = TableDefinition.where(parent_table: parent_table)
  
    # Return them as JSON (e.g. [{table_name: 'xyz', ...}, ...])
    render json: sub_defs.as_json(only: [:id, :table_name, :parent_table])
  end

  
  # === Create Multiple Features / Columns ===
  # Expect arrays for feature fields. (Make sure input names are suffixed with [] in the view.)
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
      col_name     = to_db_name(raw_name)
      next if col_name.blank?
  
      col_type     = column_types[idx]
      front_feature = features[idx]
      allowed_types = %w[string integer boolean decimal text text[] date]
      next unless allowed_types.include?(col_type)
  
      # Create & run migration
      timestamp = (Time.now + idx).strftime('%Y%m%d%H%M%S')
      migration_name = "Add#{col_name.camelcase}To#{table_name.camelcase}"
      migration_file = Rails.root.join("db/migrate/#{timestamp}_#{migration_name.underscore}.rb")
  
      migration_content = <<~RUBY
        class #{migration_name} < ActiveRecord::Migration[7.1]
          def change
            add_column :#{table_name}, :#{col_name}, :#{col_type == 'text[]' ? 'text' : col_type}#{
              if col_type == 'text[]'
                ', array: true, default: ' + (array_default_empties[idx] == '1' ? '[]' : 'nil')
              else
                ''
              end
            }
          end
        end
      RUBY
  
      File.write(migration_file, migration_content)
      system('rails db:migrate')
  
      # Gather combobox values (if combobox/checkboxes)
      raw_values = combobox_values_arr[idx].presence
      parsed_values = raw_values ? raw_values.split(',').map(&:strip) : nil
  
      # If you need to handle parent_sub data for each row, you’d parse them here:
      # For example, if you have `params[:parent_sub][idx]` => array of parent_value/sub_options
      # multiple_sub_options = {}
      # (… parse each parent-sub pair …)
  
      # Build the options hash for ColumnMetadata
      options_hash = {}
      options_hash[:values] = parsed_values if parsed_values
      # options_hash[:sub_options] = multiple_sub_options if multiple_sub_options.any?
  
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
    end
  
    msg = created_features.any? ? "Created features: #{created_features.join(', ')}" : "No features created."
    flash[created_features.any? ? :success : :error] = msg
    redirect_to admin_path(table_name: table_name, **filter_params)
  end

  # --- (Optional) Single Feature addition remains available ---
  def add_column
    table_name = params[:table_name]
    column_name = to_db_name(params[:column_name])
    column_type = params[:column_type]
    feature = params[:feature].presence
    has_cost = params[:has_cost].present?
    sub_field = params[:sub_field].presence
    rate_key = params[:rate_key].presence
    amount_key = params[:amount_key].presence
    notes_key = params[:notes_key].presence
    array_default_empty = params[:array_default_empty] == '1'

    allowed_types = %w[string integer boolean decimal text text[] date]
    unless allowed_types.include?(column_type)
      flash[:error] = 'Invalid column type!'
      redirect_to admin_path(table_name: table_name) and return
    end

    combobox_values = if %w[combobox checkboxes].include?(feature) && params[:combobox_values].present?
                        params[:combobox_values].split(',').map(&:strip)
                      else
                        []
                      end

    migration_name = "Add#{column_name.camelcase}To#{table_name.camelcase}"
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    migration_file = Rails.root.join("db/migrate/#{timestamp}_#{migration_name.underscore}.rb")
    migration_content = <<~RUBY
      class #{migration_name} < ActiveRecord::Migration[7.1]
        def change
          add_column :#{table_name}, :#{column_name}, :#{column_type == 'text[]' ? 'text' : column_type}#{
            if column_type == 'text[]'
              ', array: true, default: ' + (array_default_empty ? '[]' : 'nil')
            else
              ''
            end
          }
        end
      end
    RUBY
    File.write(migration_file, migration_content)
    system('rails db:migrate')
    ColumnMetadata.create!(
      table_name: table_name,
      column_name: column_name,
      feature: feature,
      has_cost: has_cost,
      sub_field: sub_field,
      rate_key: rate_key,
      amount_key: amount_key,
      notes_key: notes_key,
      options: { values: combobox_values.presence }.compact
    )
    flash[:success] = "Column #{column_name} added successfully to #{table_name}!"
    redirect_to admin_path(filter_params.merge(table_name: table_name))
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
    name.to_s.gsub(/[^0-9A-Za-z\s]/, '').strip.downcase.gsub(/\s+/, '_')
  end
end
