module DynamicTableManager
  extend self

  # 1) Create a new table
  def create_table(table_name)
    return if ActiveRecord::Base.connection.table_exists?(table_name)
    ActiveRecord::Base.connection.create_table(table_name) do |t|
      t.timestamps  # optional
    end
  end

  # 2) Add a column to an existing table
  def add_column(table_name, column_name, column_type, options = {})
    existing_columns = ActiveRecord::Base.connection.columns(table_name).map(&:name)
    return if existing_columns.include?(column_name.to_s)

    if options.empty?
      ActiveRecord::Base.connection.add_column(table_name, column_name, column_type)
    else
      ActiveRecord::Base.connection.add_column(table_name, column_name, column_type, options)
    end
  end

  # 3) Drop a column
  def drop_column(table_name, column_name)
    if ActiveRecord::Base.connection.column_exists?(table_name, column_name)
      ActiveRecord::Base.connection.remove_column(table_name, column_name)
    end
  end

  # 4) Create a sub-table, referencing a parent table (optional)
  def create_sub_table(sub_table_name, parent_table_name)
    return if ActiveRecord::Base.connection.table_exists?(sub_table_name)
    ActiveRecord::Base.connection.create_table(sub_table_name) do |t|
      t.references parent_table_name.singularize.to_sym, foreign_key: true
      t.timestamps
    end
  end
end
