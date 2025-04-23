namespace :add do
  desc "Add a static table and its column metadata with layout under a subsystem"
  task static_table_with_metadata: :environment do
    table_name = ENV["TABLE"]
    subsystem_name = ENV["SUBSYSTEM"]
    column_names = ENV["COLUMNS"]&.split(",")&.map(&:strip)

    if table_name.blank? || subsystem_name.blank? || column_names.blank?
      puts "❌ Usage: TABLE=table_name SUBSYSTEM='Subsystem Name' COLUMNS='col1,col2,col3' rake add:static_table_with_metadata"
      exit
    end

    # 1. Get or create subsystem
    subsystem = Subsystem.find_or_create_by!(name: subsystem_name)

    # 2. Create DB table if missing
    unless ActiveRecord::Base.connection.table_exists?(table_name)
      DynamicTableManager.create_table(table_name)
      puts "🛠️ Created new DB table: #{table_name}"
    end

    # 3. Add base columns if missing
    %i[subsystem_id supplier_id created_at updated_at].each do |core_col|
      DynamicTableManager.add_column(table_name, core_col, :bigint) if core_col.to_s.include?("id")
      DynamicTableManager.add_column(table_name, core_col, :datetime) if core_col.to_s.include?("at")
    end

    # 4. Create TableDefinition entry if missing
    table_def = TableDefinition.find_or_create_by(table_name: table_name) do |td|
      td.subsystem_id = subsystem.id
      td.static = true
      td.position = TableDefinition.where(subsystem_id: subsystem.id).maximum(:position).to_i + 1
      td.parent_table = nil
    end
    puts "✅ Registered table '#{table_name}' in table_definitions under subsystem '#{subsystem.name}'"

    # 5. Register each column in ColumnMetadata
    column_names.each_with_index do |col, idx|
      normalized = col.parameterize.underscore

      # Create the DB column if missing
      DynamicTableManager.add_column(table_name, normalized, :string)

      # Add to ColumnMetadata
      ColumnMetadata.find_or_create_by!(table_name: table_name, column_name: normalized) do |meta|
        meta.feature = "text"
        meta.row = idx + 1
        meta.col = 2
        meta.label_row = idx + 1
        meta.label_col = 1
        meta.options = {}
      end

      puts "🧩 Added metadata and column: #{normalized}"
    end

    puts "🎉 Done: Table '#{table_name}' and columns are fully registered!"
  end
end
