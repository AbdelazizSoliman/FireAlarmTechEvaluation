class AddLabelRowAndLabelColToColumnMetadatas < ActiveRecord::Migration[7.1]
  def change
    add_column :column_metadatas, :label_row, :integer
    add_column :column_metadatas, :label_col, :integer
  end
end
