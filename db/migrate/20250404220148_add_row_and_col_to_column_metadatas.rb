class AddRowAndColToColumnMetadatas < ActiveRecord::Migration[7.1]
  def change
    add_column :column_metadatas, :row, :integer
    add_column :column_metadatas, :col, :integer
  end
end
