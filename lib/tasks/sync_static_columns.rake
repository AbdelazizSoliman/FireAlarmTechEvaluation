desc "Sync static models to ColumnMetadata"
task sync_static_columns: :environment do
  static_models = TableDefinition.where(static: true).pluck(:table_name)
  static_models.each do |table_name|
    model = table_name.classify.safe_constantize
    next unless model

    model.columns.each do |col|
      next if %w[id created_at updated_at].include?(col.name)

      ColumnMetadata.find_or_create_by!(
        table_name: table_name,
        column_name: col.name
      ) do |meta|
        meta.feature = "text"
        meta.row = 1
        meta.col = 1
        meta.label_row = 0
        meta.label_col = 0
        meta.options = {}
      end
    end
  end
  puts "✅ Synced static model columns to ColumnMetadata."
end