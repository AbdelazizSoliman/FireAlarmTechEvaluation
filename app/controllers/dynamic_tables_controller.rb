class DynamicTablesController < ApplicationController
  before_action :set_table_name, only: %i[index update]

  def admin
    @subsystems = Subsystem.all.pluck(:name, :id) # Fetch subsystems for dropdown
    @table_name = params[:table_name] || ''
    @existing_columns = @table_name.present? ? ActiveRecord::Base.connection.columns(@table_name).map(&:name) : []
    @existing_tables = ActiveRecord::Base.connection.tables - %w[schema_migrations ar_internal_metadata] # List all tables except Rails internals
  end

  def add_column
    table_name = params[:table_name]
    column_name = params[:column_name].strip.downcase
    column_type = params[:column_type]

    allowed_types = %w[string integer boolean decimal text date]
    unless allowed_types.include?(column_type)
      flash[:error] = 'Invalid column type!'
      redirect_to admin_path and return
    end

    migration_name = "Add#{column_name.camelcase}To#{table_name.camelcase}"
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    migration_file = Rails.root.join("db/migrate/#{timestamp}_#{migration_name.underscore}.rb")

    migration_content = <<-RUBY
      class #{migration_name} < ActiveRecord::Migration[7.0]
        def change
          add_column :#{table_name}, :#{column_name}, :#{column_type}
        end
      end
    RUBY

    File.write(migration_file, migration_content)
    system('rails db:migrate')

    flash[:success] = "Column #{column_name} added successfully!"
    redirect_to admin_path(table_name: table_name)
  end

  def create_table
    subsystem_id = params[:subsystem_id]
    table_name = params[:table_name].strip.downcase
    columns = params[:columns] || [] # Expecting an array of {name: "col_name", type: "col_type"}

    # Validate table name
    if table_name.blank? || !table_name.match(/^[a-z_]+$/)
      flash[:error] = 'Invalid table name! Use lowercase letters and underscores only.'
      redirect_to admin_path and return
    end

    # Check if table already exists
    if ActiveRecord::Base.connection.table_exists?(table_name)
      flash[:error] = "Table '#{table_name}' already exists!"
      redirect_to admin_path and return
    end

    # Validate columns
    allowed_types = %w[string integer boolean decimal text date]
    columns.each do |col|
      unless allowed_types.include?(col[:type])
        flash[:error] = "Invalid column type '#{col[:type]}' for '#{col[:name]}'!"
        redirect_to admin_path and return
      end
    end

    # Generate migration
    migration_name = "Create#{table_name.camelcase}"
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    migration_file = Rails.root.join("db/migrate/#{timestamp}_#{migration_name.underscore}.rb")

    migration_content = <<-RUBY
      class #{migration_name} < ActiveRecord::Migration[7.0]
        def change
          create_table :#{table_name} do |t|
            #{columns.map { |col| "t.#{col[:type]} :#{col[:name]}" }.join("\n            ")}
            t.bigint :subsystem_id, null: false
            t.datetime :created_at, null: false
            t.datetime :updated_at, null: false

            t.index [:subsystem_id], name: "index_#{table_name}_on_subsystem_id"
          end

          add_foreign_key :#{table_name}, :subsystems
        end
      end
    RUBY

    File.write(migration_file, migration_content)
    system('rails db:migrate')

    flash[:success] = "Table '#{table_name}' created successfully!"
    redirect_to admin_path
  end

  private

  def set_table_name
    allowed_tables = ActiveRecord::Base.connection.tables - %w[schema_migrations ar_internal_metadata]
    @table_name = params[:table_name]

    return if allowed_tables.include?(@table_name)

    render json: { error: 'Invalid table name' }, status: :unprocessable_entity
  end
end
