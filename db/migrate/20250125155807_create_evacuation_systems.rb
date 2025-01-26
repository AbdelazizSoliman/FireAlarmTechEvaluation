class CreateEvacuationSystems < ActiveRecord::Migration[7.1]
  def change
    create_table :evacuation_systems do |t|
      t.string :bms_connection
      t.string :elevator_control_system
      t.string :fire_suppression_system
      t.string :staircase_pressurization_system
      t.string :hvac_system
      t.string :cctv_system
      t.string :access_control_system
      t.string :pa_va_system
      t.string :lighting_control_system
      t.string :electrical_panels
      t.integer :no_of_interface_modules
      t.integer :total_no_of_control_modules
      t.integer :total_no_of_monitor_modules
      t.integer :total_no_of_dual_monitor_modules
      t.integer :total_no_of_zone_module
      t.references :subsystem, null: false, foreign_key: true

      t.timestamps
    end
  end
end
