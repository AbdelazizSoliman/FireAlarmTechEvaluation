class CreateSpareParts < ActiveRecord::Migration[7.1]
  def change
    create_table :spare_parts do |t|
      t.integer :total_no_of_device1
      t.integer :total_no_of_device2
      t.integer :total_no_of_device3
      t.integer :total_no_of_device4
      t.references :subsystem, null: false, foreign_key: true
      
      t.timestamps
    end
  end
end
