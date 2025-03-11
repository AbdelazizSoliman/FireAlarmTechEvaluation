class CreateColumnMetadata < ActiveRecord::Migration[7.1]
  def change
    create_table :column_metadatas do |t|
      t.string :table_name, null: false
      t.string :column_name, null: false
      t.string :feature
      t.jsonb :options, default: {}, null: false
      t.timestamps
    end
    add_index :column_metadatas, [:table_name, :column_name], unique: true
  end
end
