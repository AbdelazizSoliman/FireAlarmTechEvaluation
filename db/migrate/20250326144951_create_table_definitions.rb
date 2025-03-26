class CreateTableDefinitions < ActiveRecord::Migration[7.1]
  def change
    create_table :table_definitions do |t|
      t.string  :table_name,   null: false
      t.integer :subsystem_id, null: false
      t.string  :parent_table 

      t.timestamps
    end
  end
end
