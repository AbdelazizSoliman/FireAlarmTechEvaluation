class DynamicTablesController < ApplicationController
  before_action :set_table_name, only: %i[index update]

  # GET /dynamic_tables/:table_name
  def index
    # Fetch column names dynamically
    columns = ActiveRecord::Base.connection.columns(@table_name).map(&:name)

    # Fetch all records from the table
    records = ActiveRecord::Base.connection.execute("SELECT * FROM #{@table_name}").to_a

    render json: { columns: columns, data: records }
  end

  # PATCH /dynamic_tables/:table_name/:id
  def update
    record_id = params[:id]
    update_params = params.except(:table_name, :id, :controller, :action)

    # Generate dynamic SQL for updating the record
    set_clause = update_params.map { |key, value| "#{key} = #{ActiveRecord::Base.connection.quote(value)}" }.join(', ')
    sql = "UPDATE #{@table_name} SET #{set_clause} WHERE id = #{record_id}"

    ActiveRecord::Base.connection.execute(sql)
    render json: { message: 'Record updated successfully!' }
  end

  def admin
    # Fetch existing columns if a table is selected
    return unless params[:table_name].present?

    @existing_columns = ActiveRecord::Base.connection.columns(params[:table_name]).map(&:name)
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
    redirect_to admin_path
  end

  private

  def set_table_name
    allowed_tables = %w[
      connection_betweens detectors_field_devices door_holders evacuation_systems
      fire_alarm_control_panels general_commercial_data graphic_systems
      interface_with_other_systems isolations manual_pull_stations material_and_deliveries
      notification_devices product_data scope_of_works spare_parts telephone_systems
      prerecorded_message_audio_modules supplier_data
    ]

    @table_name = params[:table_name]

    return if allowed_tables.include?(@table_name)

    render json: { error: 'Invalid table name' }, status: :unprocessable_entity
  end
end
