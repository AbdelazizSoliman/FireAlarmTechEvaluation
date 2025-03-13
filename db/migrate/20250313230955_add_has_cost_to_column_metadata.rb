class AddHasCostToColumnMetadata < ActiveRecord::Migration[7.1]
  def change
    add_column :column_metadata, :has_cost, :boolean, default: false, null: false
  end
end
