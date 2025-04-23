namespace :sync do
  desc "Sync legacy static tables and columns to TableDefinition and ColumnMetadata"
  task legacy_tables: :environment do
    system_tables = %w[
      schema_migrations ar_internal_metadata
      active_storage_blobs active_storage_attachments active_storage_variant_records
    ]

    excluded_non_subsystem_tables = %w[
      users projects admins notifications suppliers sessions
    ]

    all_db_tables = ActiveRecord::Base.connection.tables - system_tables - excluded_non_subsystem_tables

    all_db_tables.each do |table|
      columns = ActiveRecord::Base.connection.columns(table).map(&:name)

      # 🚫 Skip tables that are not subsystem-related
      next unless columns.include?("subsystem_id")

      # ✅ Register in TableDefinition
      table_def = TableDefinition.find_or_create_by(table_name: table) do |td|
        td.static = true
        td.subsystem_id = ActiveRecord::Base.connection.select_value("SELECT subsystem_id FROM #{table} LIMIT 1") || Subsystem.first&.id || 1
        td.position = TableDefinition.where(subsystem_id: td.subsystem_id).maximum(:position).to_i + 1
        puts "✅ Added TableDefinition: #{table}"
      end

      # 🧩 Sync each column to ColumnMetadata
      columns.each do |col|
        next if %w[id created_at updated_at subsystem_id supplier_id].include?(col)

        unless ColumnMetadata.exists?(table_name: table, column_name: col)
          ColumnMetadata.create!(
            table_name: table,
            column_name: col,
            feature: "text",
            row: 1,
            col: 1,
            label_row: 0,
            label_col: 0,
            options: {}
          )
          puts "🧩 Added ColumnMetadata for #{table}.#{col}"
        end
      end
    end

    puts "🎉 Sync complete! Subsystem-related legacy tables and columns are now registered."
  end
end
