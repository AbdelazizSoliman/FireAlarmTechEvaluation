class CreateDoorHolders < ActiveRecord::Migration[7.1]
  def change
    create_table :door_holders do |t|
      t.integer :total_no_of_devices
      t.integer :total_no_of_devices_unit_rate
      t.integer :total_no_of_devices_amount
      t.text :total_no_of_devices_notes
      t.integer :total_no_of_relays
      t.integer :total_no_of_relays_unit_rate
      t.integer :total_no_of_relays_amount
      t.text :total_no_of_relays_notes
      t.references :subsystem, null: false, foreign_key: true

      t.timestamps
    end
  end
end
