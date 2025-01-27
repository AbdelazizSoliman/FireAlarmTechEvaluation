class CreateEvacuationSystems < ActiveRecord::Migration[7.1]
  def change
    create_table :evacuation_systems do |t|
      t.string :included_in_fire_alarm_system
      t.string :evacuation_system_part_of_fa_panel
      t.integer :amplifier_power_output
      t.integer :total_no_of_amplifiers
      t.integer :total_no_of_evacuation_speakers_circuits
      t.integer :total_no_of_wattage_per_panel
      t.decimal :fire_rated_speakers_watt
      t.decimal :speakers_tapping_watt
      t.integer :total_no_of_speakers
      t.references :subsystem, null: false, foreign_key: true

      t.timestamps
    end
  end
end
