# lib/tasks/sync_static_tables.rake
namespace :sync do
  desc "Insert static tables with subsystem_id column into table_definitions"
  task legacy_tables: :environment do
    # Get a list of all tables in the database
    tables = ActiveRecord::Base.connection.tables

    # Loop through each table
    tables.each_with_index do |table, index|
      # Skip the tables that are clearly not related to subsystems (e.g., 'users', 'projects')
      next if table.match?(/users|projects/i)

      # Skip if the table has no subsystem_id column
      columns = ActiveRecord::Base.connection.columns(table).map(&:name)
      next unless columns.include?("subsystem_id")

      # If the table is not in TableDefinition, create an entry
      unless TableDefinition.exists?(table_name: table)
        # Fetch a sample row to extract the subsystem_id
        sample_row = ActiveRecord::Base.connection.select_one("SELECT subsystem_id FROM #{table} LIMIT 1")
        subsystem_id = sample_row&.dig("subsystem_id")

        # If a valid subsystem_id is found, add the table to table_definitions
        if subsystem_id
          TableDefinition.create!(
            table_name: table,
            subsystem_id: subsystem_id,
            parent_table: nil,  # Update based on your table hierarchy, if any
            is_static: true,
            position: index + 1  # Optional: Position in list for ordering, adjust as needed
          )
          puts "✅ Synced table #{table} with subsystem_id #{subsystem_id}"
        else
          puts "⚠️ Skipped #{table} — no valid subsystem_id found"
        end
      else
        puts "⚠️ Skipped #{table} — already exists in table_definitions"
      end
    end
  end
end
