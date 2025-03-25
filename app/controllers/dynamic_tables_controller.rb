class DynamicTablesController < ApplicationController
  before_action :set_table_name, only: [:add_column]

  def admin
    # Fetch all projects for initial dropdown
    @projects = Project.all.pluck(:name, :id)
    @project_filter = params[:project_filter]
    @project_scope_filter = params[:project_scope_filter]
    @system_filter = params[:system_filter]
    @subsystem_filter = params[:subsystem_filter]

    # Filter project scopes based on selected project
    @project_scopes = if @project_filter.present?
                        Project.find(@project_filter).project_scopes.pluck(:name, :id)
                      else
                        []
                      end

    # Filter systems based on selected project scope
    @systems = if @project_scope_filter.present?
                 ProjectScope.find(@project_scope_filter).systems.pluck(:name, :id)
               else
                 []
               end

    # Filter subsystems based on selected system
    @subsystems = if @system_filter.present?
                    System.find(@system_filter).subsystems.pluck(:name, :id)
                  else
                    []
                  end

    # Only list tables that have a 'subsystem_id' column and match the selected subsystem
    @subsystem_tables = if @subsystem_filter.present?
                          ActiveRecord::Base.connection.tables.select do |table|
                            ActiveRecord::Base.connection.columns(table).any? { |col| col.name == 'subsystem_id' }
                          end
                        else
                          []
                        end

    # Set @table_name if it exists in the DB
    @table_name = params[:table_name] if params[:table_name].present? &&
                                         ActiveRecord::Base.connection.table_exists?(params[:table_name])

    # List existing columns with their metadata for the chosen table
    @existing_columns = if @table_name.present? && ActiveRecord::Base.connection.table_exists?(@table_name)
                          ActiveRecord::Base.connection.columns(@table_name).map do |col|
                            metadata = ColumnMetadata.find_by(table_name: @table_name, column_name: col.name)
                            {
                              name: col.name,
                              type: col.type,
                              metadata: metadata
                            }
                          end
                        else
                          []
                        end
  end

  def create_table
    subsystem_id = params[:subsystem_id]
    table_name = to_db_name(params[:table_name])

    columns = params[:columns].map do |col|
      {
        'name' => to_db_name(col['name']),
        'type' => col['type'],
        'array_default_empty' => col['array_default_empty']
      }
    end

    migration_name = "Create#{table_name.camelcase}"
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    migration_file = Rails.root.join("db/migrate/#{timestamp}_#{migration_name.underscore}.rb")

    migration_content = <<-RUBY
      class #{migration_name} < ActiveRecord::Migration[7.1]
        def change
          create_table :#{table_name}, force: :cascade do |t|
            #{columns.map do |col|
              if col['type'] == 'text[]'
                "t.text :#{col['name']}, array: true, default: #{col['array_default_empty'] == '1' ? '[]' : 'nil'}"
              else
                "t.#{col['type']} :#{col['name']}"
              end
            end.join("\n            ")}
            t.bigint :subsystem_id, null: false
            t.bigint :supplier_id, null: false
            t.datetime :created_at, null: false
            t.datetime :updated_at, null: false
            t.index [:subsystem_id], name: "index_#{table_name}_on_subsystem_id"
            t.index [:supplier_id, :subsystem_id], name: "idx_#{table_name}_sup_sub", unique: true
            t.index [:supplier_id], name: "index_#{table_name}_on_supplier_id"
          end
        end
      end
    RUBY

    File.write(migration_file, migration_content)
    system('rails db:migrate')

    flash[:success] = "Table #{table_name} created successfully!"
    redirect_to admin_path
  end

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

    flash[:success] = "Column #{column_name} added successfully!"
    redirect_to admin_path(table_name: table_name)
  end

  def show
    @table_name = params[:table_name]
    unless ActiveRecord::Base.connection.table_exists?(@table_name)
      render json: { error: "Table not found" }, status: :not_found and return
    end
    records = ActiveRecord::Base.connection.select_all("SELECT * FROM #{@table_name}")
    metadata = ColumnMetadata.where(table_name: @table_name).as_json
    render json: { records: records, metadata: metadata }
  end

  def show_with_subsystem
    @subsystem_id = params[:subsystem_id]
    @table_name = params[:table_name]
  end

  def edit_metadata
    @table_name = params[:table_name]
    @column_name = params[:column_name]
    unless ActiveRecord::Base.connection.table_exists?(@table_name) &&
           ActiveRecord::Base.connection.column_exists?(@table_name, @column_name)
      flash[:error] = "Column #{@column_name} in table #{@table_name} does not exist!"
      redirect_to admin_path(table_name: @table_name) and return
    end
    @metadata = ColumnMetadata.find_by(table_name: @table_name, column_name: @column_name) ||
                ColumnMetadata.new(table_name: @table_name, column_name: @column_name)
  end

  def update_metadata
    @table_name = params[:table_name]
    @column_name = params[:column_name]
    unless ActiveRecord::Base.connection.table_exists?(@table_name) &&
           ActiveRecord::Base.connection.column_exists?(@table_name, @column_name)
      flash[:error] = "Column #{@column_name} in table #{@table_name} does not exist!"
      redirect_to admin_path(table_name: @table_name) and return
    end

    metadata_params = params.require(:column_metadata).permit(
      :feature, :has_cost, :sub_field, :rate_key, :amount_key, :notes_key,
      options: [:values, :sub_options]
    ).to_h.deep_symbolize_keys

    # Process options if present
    if metadata_params[:options].present?
      metadata_params[:options][:values] = metadata_params[:options][:values].split(',').map(&:strip) if metadata_params[:options][:values].is_a?(String)
      metadata_params[:options][:sub_options] = metadata_params[:options][:sub_options].transform_keys(&:to_s) if metadata_params[:options][:sub_options].present?
    end

    @metadata = ColumnMetadata.find_or_initialize_by(table_name: @table_name, column_name: @column_name)
    if @metadata.update(metadata_params)
      flash[:success] = "Metadata for #{@column_name} updated successfully!"
      redirect_to admin_path(table_name: @table_name)
    else
      flash[:error] = "Failed to update metadata: #{@metadata.errors.full_messages.join(', ')}"
      render :edit_metadata
    end
  end

  private

  def set_table_name
    @table_name = params[:table_name]
    return if ActiveRecord::Base.connection.table_exists?(@table_name)

    flash[:error] = "Table #{@table_name} does not exist!"
    redirect_to admin_path and return
  end

  def to_db_name(name)
    name.to_s.gsub(/[^0-9A-Za-z\s]/, '').strip.downcase.gsub(/\s+/, '_')
  end
end