class DynamicTablesController < ApplicationController
  before_action :set_table_name, only: [:add_column]

  def admin
    @subsystems = Subsystem.pluck(:name, :id) # Adjust based on your Subsystem model
    @subsystem_filter = params[:subsystem_filter]
    @subsystem_tables = if @subsystem_filter.present?
                          ActiveRecord::Base.connection.tables.select do |table|
                            ActiveRecord::Base.connection.columns(table).any? { |col| col.name == 'subsystem_id' }
                          end
                        else
                          []
                        end
    if params[:table_name].present? && ActiveRecord::Base.connection.table_exists?(params[:table_name])
      @table_name = params[:table_name]
    end
    @existing_columns = if @table_name.present? && ActiveRecord::Base.connection.table_exists?(@table_name)
                          ActiveRecord::Base.connection.columns(@table_name).map(&:name)
                        else
                          []
                        end
  end

  def create_table
    subsystem_id = params[:subsystem_id]
    table_name = params[:table_name].strip.downcase
    columns = params[:columns].map do |col|
      { 'name' => col['name'].strip.downcase, 'type' => col['type'],
        'array_default_empty' => col['array_default_empty'] }
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
    column_name = params[:column_name].strip.downcase
    column_type = params[:column_type]
    feature = params[:feature].presence
    combobox_values = params[:combobox_values].split(',').map(&:strip) if %w[combobox checkboxes].include?(feature)
    sub_options = JSON.parse(params[:sub_options]) if params[:sub_options].present?
    sub_field = params[:sub_field].presence
    has_cost = params[:has_cost].present?
    rate_key = params[:rate_key].presence
    amount_key = params[:amount_key].presence
    notes_key = params[:notes_key].presence
    array_default_empty = params[:array_default_empty] == '1'

    allowed_types = %w[string integer boolean decimal text text[] date]
    unless allowed_types.include?(column_type)
      flash[:error] = 'Invalid column type!'
      redirect_to admin_path(table_name: table_name) and return
    end

    migration_name = "Add#{column_name.camelcase}To#{table_name.camelcase}"
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    migration_file = Rails.root.join("db/migrate/#{timestamp}_#{migration_name.underscore}.rb")

    migration_content = <<~RUBY
      class #{migration_name} < ActiveRecord::Migration[7.1]
        def change
          add_column :#{table_name}, :#{column_name}, :#{column_type == 'text[]' ? 'text' : column_type}#{if column_type == 'text[]'
                                                                                                            ', array: true, default: ' + (array_default_empty ? '[]' : 'nil')
                                                                                                          else
                                                                                                            ''
                                                                                                          end}
        end
      end
    RUBY

    File.write(migration_file, migration_content)
    system('rails db:migrate')

    if feature.present?
      ColumnMetadata.create!(
        table_name: table_name,
        column_name: column_name,
        feature: feature,
        has_cost: has_cost,
        sub_field: sub_field,
        rate_key: rate_key,
        amount_key: amount_key,
        notes_key: notes_key,
        options: case feature
                 when 'combobox'
                   { values: combobox_values, sub_options: sub_options }.compact
                 when 'checkboxes'
                   { values: combobox_values }
                 else
                   {}
                 end
      )
    end

    flash[:success] = "Column #{column_name} added successfully!"
    redirect_to admin_path(table_name: table_name)
  end

  def show
    @table_name = params[:table_name]
    render 'show'
  end

  private

  def set_table_name
    @table_name = params[:table_name]
    return if ActiveRecord::Base.connection.table_exists?(@table_name)

    flash[:error] = "Table #{@table_name} does not exist!"
    redirect_to admin_path and return
  end
end
