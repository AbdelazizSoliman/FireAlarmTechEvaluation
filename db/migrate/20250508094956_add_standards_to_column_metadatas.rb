class AddStandardsToColumnMetadatas < ActiveRecord::Migration[7.1]
  def change
    add_column :column_metadatas, :standard_value, :decimal, precision: 12, scale: 4
    add_column :column_metadatas, :tolerance, :decimal, precision: 5, scale: 2
  end
end
