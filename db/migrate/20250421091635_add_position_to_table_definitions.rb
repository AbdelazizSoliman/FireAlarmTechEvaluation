class AddPositionToTableDefinitions < ActiveRecord::Migration[7.1]
  def change
    add_column :table_definitions, :position, :integer
  end
end
