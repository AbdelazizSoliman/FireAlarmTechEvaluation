class DynamicTablesController < ApplicationController
  before_action :set_table_name, only: [:add_column]

  def admin
    # --- Filters for Project, Discipline, System, and Subsystem ---
    @projects = Project.all.pluck(:name, :id)
    @project_filter = params[:project_filter]
    @project_scope_filter = params[:project_scope_filter]
    @system_filter = params[:system_filter]
    @subsystem_filter = params[:subsystem_filter]

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

    # --- Load table definitions if a subsystem is selected ---
    if @subsystem_filter.present?
      table_defs = TableDefinition.where(subsystem_id: @subsystem_filter)
      @main_tables = table_defs.where(parent_table: nil)
      @sub_tables  = table_defs.where.not(parent_table: nil)
    else
      @main_tables = []
      @sub_tables = []
    end

    # --- If a table is selected, load its columns (with metadata) ---
    @table_name = params[:table_name] if params[:table_name].present? &&
                                         ActiveRecord::Base.connection.table_exists?(params[:table_name])
    @existing_columns = if @table_name.present?
                          ActiveRecord::Base.connection.columns(@table_name).map do |col|
                            metadata = ColumnMetadata.find_by(table_name: @table_name, column_name: col.name)
                            { name: col.name, type: col.type, metadata: metadata }
                          end
                        else
                          []
                        end
  end

  # --- Action to Create Multiple Main Tables ---
  # This action allows users to add several table names via a dynamic form.
  # It skips any table that already exists and collects those names to flash to the user.
  def create_multiple_tables
    subsystem_id = params[:subsystem_id]
    raw_table_names = params[:table_names] || []

    if raw_table_names.blank?
      flash[:error] = "Please add at least one table name."
      redirect_to admin_path(filter_params) and return
    end

    duplicate_tables = []
    created_tables   = []

    raw_table_names.each_with_index do |raw_name, idx|
      table_name = to_db_name(raw_name)
      next if table_name.blank?

      # Skip creation if the table already exists.
      if ActiveRecord::Base.connection.table_exists?(table_name)
        duplicate_tables << table_name
        next
      end

      # Generate a unique timestamp per table so migrations won’t collide.
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

      # Save the table definition record (indicating a main table)
      TableDefinition.create!(
        table_name: table_name,
        subsystem_id: subsystem_id,
        parent_table: nil
      )

      created_tables << table_name
    end

    msg = ""
    msg += "Tables already exist: #{duplicate_tables.join(', ')}. " if duplicate_tables.any?
    msg += "Created tables: #{created_tables.join(', ')} successfully." if created_tables.any?

    if created_tables.empty?
      flash[:error] = msg
    else
      flash[:success] = msg
    end

    redirect_to admin_path(filter_params)
  end

  # --- Add Column Action (unchanged) ---
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

    multiple_sub_options = {}
    if params[:has_sub_options].present? && params[:parent_sub].present?
      params[:parent_sub].each do |pair|
        parent = pair['parent_value']&.strip
        subs = pair['sub_options']&.split(',')&.map(&:strip) || []
        next if parent.blank? || subs.empty?
        multiple_sub_options[parent] = subs
      end
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
      options: {
        values: combobox_values.presence,
        sub_options: multiple_sub_options.presence
      }.compact
    )

    flash[:success] = "Column #{column_name} added successfully to #{table_name}!"
    redirect_to admin_path(filter_params.merge(table_name: table_name))
  end

  # --- Create Sub-Table Action (similar pattern) ---
  def create_sub_table
    subsystem_id = params[:subsystem_id]
    sub_table_name = to_db_name(params[:sub_table_name])
    parent_table = params[:parent_table]

    if ActiveRecord::Base.connection.table_exists?(sub_table_name)
      flash[:error] = "Table #{sub_table_name} already exists."
      redirect_to admin_path(filter_params) and return
    end

    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
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

    TableDefinition.create!(
      table_name: sub_table_name,
      subsystem_id: subsystem_id,
      parent_table: parent_table
    )

    flash[:success] = "Sub Table #{sub_table_name} created successfully!"
    redirect_to admin_path(filter_params)
  end

  private

  # Permit and pass along filter parameters
  def filter_params
    params.permit(:project_filter, :project_scope_filter, :system_filter, :subsystem_filter)
  end

  # Before-action to ensure the given table exists for actions like add_column.
  def set_table_name
    @table_name = params[:table_name]
    unless @table_name.present? && ActiveRecord::Base.connection.table_exists?(@table_name)
      flash[:error] = "Table #{@table_name} does not exist!"
      redirect_to admin_path and return
    end
  end

  # Helper to convert names into a DB-friendly format.
  def to_db_name(name)
    name.to_s.gsub(/[^0-9A-Za-z\s]/, '').strip.downcase.gsub(/\s+/, '_')
  end
end
