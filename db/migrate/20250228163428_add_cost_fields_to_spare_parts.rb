class AddCostFieldsToSpareParts < ActiveRecord::Migration[7.1]
  def change
    change_table :spare_parts do |t|
      # For total_no_of_device1
      t.integer :total_no_of_device1_unit_rate
      t.integer :total_no_of_device1_amount
      t.text    :total_no_of_device1_notes

      # For total_no_of_device2
      t.integer :total_no_of_device2_unit_rate
      t.integer :total_no_of_device2_amount
      t.text    :total_no_of_device2_notes

      # For total_no_of_device3
      t.integer :total_no_of_device3_unit_rate
      t.integer :total_no_of_device3_amount
      t.text    :total_no_of_device3_notes

      # For total_no_of_device4
      t.integer :total_no_of_device4_unit_rate
      t.integer :total_no_of_device4_amount
      t.text    :total_no_of_device4_notes
    end
  end
end
