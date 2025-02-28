class AddCostFieldsToTelephoneSystems < ActiveRecord::Migration[7.1]
  def change
    change_table :telephone_systems do |t|
      # For number_of_firefighter_telephone_circuits_per_panel
      t.integer :number_of_firefighter_telephone_circuits_per_panel_unit_rate
      t.integer :number_of_firefighter_telephone_circuits_per_panel_amount
      t.text    :number_of_firefighter_telephone_circuits_per_panel_notes

      # For total_no_of_firefighter_telephone_cabinet
      t.integer :total_no_of_firefighter_telephone_cabinet_unit_rate
      t.integer :total_no_of_firefighter_telephone_cabinet_amount
      t.text    :total_no_of_firefighter_telephone_cabinet_notes

      # For total_no_of_firefighter_phones
      t.integer :total_no_of_firefighter_phones_unit_rate
      t.integer :total_no_of_firefighter_phones_amount
      t.text    :total_no_of_firefighter_phones_notes

      # For total_no_of_firefighter_jacks
      t.integer :total_no_of_firefighter_jacks_unit_rate
      t.integer :total_no_of_firefighter_jacks_amount
      t.text    :total_no_of_firefighter_jacks_notes
    end
  end
end
