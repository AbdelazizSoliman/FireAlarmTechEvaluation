class AddStaticToTableDefinitions < ActiveRecord::Migration[7.1]
  def change
    add_column :table_definitions, :static, :boolean
  end
end
