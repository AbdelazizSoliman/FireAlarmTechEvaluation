class AddCostFieldsToEvacuationSystems < ActiveRecord::Migration[7.1]
  def change
    change_table :evacuation_systems do |t|
      # For amplifier_power_output
      t.integer :amplifier_power_output_unit_rate
      t.integer :amplifier_power_output_amount
      t.text    :amplifier_power_output_notes

      # For total_no_of_amplifiers
      t.integer :total_no_of_amplifiers_unit_rate
      t.integer :total_no_of_amplifiers_amount
      t.text    :total_no_of_amplifiers_notes

      # For total_no_of_evacuation_speakers_circuits
      t.integer :total_no_of_evacuation_speakers_circuits_unit_rate
      t.integer :total_no_of_evacuation_speakers_circuits_amount
      t.text    :total_no_of_evacuation_speakers_circuits_notes

      # For total_no_of_wattage_per_panel
      t.integer :total_no_of_wattage_per_panel_unit_rate
      t.integer :total_no_of_wattage_per_panel_amount
      t.text    :total_no_of_wattage_per_panel_notes

      # For total_no_of_speakers
      t.integer :total_no_of_speakers_unit_rate
      t.integer :total_no_of_speakers_amount
      t.text    :total_no_of_speakers_notes
    end
  end
end
