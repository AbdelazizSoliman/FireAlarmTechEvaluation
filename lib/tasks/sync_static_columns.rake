# lib/tasks/sync_static_columns.rake
namespace :sync do
  desc "Sync legacy static tables and columns into table_definitions and column_metadatas"
  task legacy_tables: :environment do
    puts "🔍 Scanning legacy tables..."

    existing_tables = ActiveRecord::Base.connection.tables
    system_tables = %w[schema_migrations ar_internal_metadata active_storage_blobs active_storage_attachments active_storage_variant_records]

    existing_tables.each do |table|
      next if system_tables.include?(table)
      next if table.start_with?("pg_")

      # Check if it already exists
      td = TableDefinition.find_or_initialize_by(table_name: table)

      unless td.persisted?
        # Try to infer subsystem_id from first row, if exists
        subsystem_id = nil
        if ActiveRecord::Base.connection.columns(table).map(&:name).include?("subsystem_id")
          row = ActiveRecord::Base.connection.exec_query("SELECT subsystem_id FROM #{table} LIMIT 1").first
          subsystem_id = row&.dig("subsystem_id")
        end

        td.subsystem_id = subsystem_id
        td.static = true
        td.save!
        puts "✅ Added TableDefinition: #{table}"
      end

      # Sync column_metadatas
      existing_column_names = ColumnMetadata.where(table_name: table).pluck(:column_name)

      ActiveRecord::Base.connection.columns(table).each do |col|
        next if existing_column_names.include?(col.name)

        ColumnMetadata.create!(
          table_name: table,
          column_name: col.name,
          options: { allowed_values: [] }
        )
        puts "🧩 Added ColumnMetadata for #{table}.#{col.name}"
      end
    end

    puts "🎉 Legacy static table sync complete!"
  end
end
