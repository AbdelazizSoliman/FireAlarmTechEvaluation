class AddHasCostToColumnMetadatas < ActiveRecord::Migration[7.1]
  def change
    add_column :column_metadatas, :has_cost, :boolean, default: false, null: false
  end
end
