class AddPositionToTableDefinitions < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:table_definitions, :position)
      add_column :table_definitions, :position, :integer
    end
  end
end
