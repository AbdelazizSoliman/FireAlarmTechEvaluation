class DynamicTablesController < ApplicationController
  before_action :set_table_name, only: [:add_column]

  def admin
    @subsystems = Subsystem.pluck(:name, :id)
    @subsystem_filter = params[:subsystem_filter]

    # Only list tables that have a 'subsystem_id' column
    @subsystem_tables = if @subsystem_filter.present?
                          ActiveRecord::Base.connection.tables.select do |table|
                            ActiveRecord::Base.connection.columns(table).any? { |col| col.name == 'subsystem_id' }
                          end
                        else
                          []
                        end

    # Set @table_name if it actually exists in the DB
    @table_name = params[:table_name] if params[:table_name].present? &&
                                         ActiveRecord::Base.connection.table_exists?(params[:table_name])

    # List existing columns for the chosen table
    @existing_columns = if @table_name.present? &&
                           ActiveRecord::Base.connection.table_exists?(@table_name)
                          ActiveRecord::Base.connection.columns(@table_name).map(&:name)
                        else
                          []
                        end
  end

  def create_table
    subsystem_id = params[:subsystem_id]
    # Downcase + strip the table name so we don't get spaces or uppercase
    table_name = params[:table_name].to_s.strip.downcase

    columns = params[:columns].map do |col|
      {
        'name'               => col['name'].to_s.strip.downcase,
        'type'               => col['type'],
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
    # Basic parameters
    table_name          = params[:table_name]
    column_name         = params[:column_name].to_s.strip.downcase
    column_type         = params[:column_type]
    feature             = params[:feature].presence
    sub_field           = params[:sub_field].presence
    has_cost            = params[:has_cost].present?
    rate_key            = params[:rate_key].presence
    amount_key          = params[:amount_key].presence
    notes_key           = params[:notes_key].presence
    array_default_empty = params[:array_default_empty] == '1'

    # Validate column type
    allowed_types = %w[string integer boolean decimal text text[] date]
    unless allowed_types.include?(column_type)
      flash[:error] = 'Invalid column type!'
      redirect_to admin_path(table_name: table_name) and return
    end

    # Prepare combobox/checkboxes values if applicable
    if %w[combobox checkboxes].include?(feature) && params[:combobox_values].present?
      combobox_values = params[:combobox_values].split(',').map(&:strip)
    else
      combobox_values = []
    end

    # Build a multiple_sub_options hash from parent_sub array
    # This allows you to define multiple parent values, each with its own sub-options
    multiple_sub_options = {}
    if params[:has_sub_options].present? && params[:parent_sub].present?
      params[:parent_sub].each do |pair|
        parent = pair["parent_value"]&.strip
        subs   = pair["sub_options"]&.split(",")&.map(&:strip) || []
        next if parent.blank? || subs.empty?

        multiple_sub_options[parent] = subs
      end
    end

    # Create a new migration to add the column
    migration_name = "Add#{column_name.camelcase}To#{table_name.camelcase}"
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    migration_file = Rails.root.join("db/migrate/#{timestamp}_#{migration_name.underscore}.rb")

    # If text[] => add_column :table, :column, :text, array: true, default: []
    # Otherwise => add_column :table, :column, :column_type
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

    # If this is a combobox and sub-options are required but missing, handle it
    if feature == 'combobox' && params[:has_sub_options].present? && multiple_sub_options.empty?
      flash[:error] = "You selected sub-options, but none were provided!"
      redirect_to admin_path(table_name: table_name) and return
    end

    # Store metadata if a front-end feature is selected
    if feature.present?
      # Make sure your column_metadatas table has all these columns:
      # has_cost, feature, etc. Otherwise you'll get UnknownAttributeError.
      ColumnMetadata.create!(
        table_name:  table_name,
        column_name: column_name,
        feature:     feature,
        has_cost:    has_cost,
        sub_field:   sub_field,
        rate_key:    rate_key,
        amount_key:  amount_key,
        notes_key:   notes_key,
        options: {
          values:      combobox_values.presence,
          sub_options: multiple_sub_options.presence
        }.compact
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
