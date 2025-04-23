namespace :sync do
  desc "Insert static tables with subsystem_id column into table_definitions"
  task legacy_tables: :environment do
    tables = ActiveRecord::Base.connection.tables

    tables.each do |table|
      next if table.match?(/users|projects/i)

      columns = ActiveRecord::Base.connection.columns(table).map(&:name)
      next unless columns.include?("subsystem_id")

      unless TableDefinition.exists?(table_name: table)
        sample_row = ActiveRecord::Base.connection.select_one("SELECT subsystem_id FROM #{table} LIMIT 1")
        subsystem_id = sample_row&.dig("subsystem_id")

        if subsystem_id
          position = TableDefinition.where(subsystem_id: subsystem_id).maximum(:position).to_i + 1
          TableDefinition.create!(
            table_name: table,
            subsystem_id: subsystem_id,
            parent_table: nil,
            is_static: true,
            position: position
          )
          puts "✅ Synced table #{table} with subsystem_id #{subsystem_id}, position #{position}"
        else
          puts "⚠️ Skipped #{table} — no valid subsystem_id found"
        end
      else
        puts "⚠️ Skipped #{table} — already exists in table_definitions"
      end
    end
  end
end
