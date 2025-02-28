class RenameAndAddCostFieldsToInterfaceWithOtherSystems < ActiveRecord::Migration[7.1]
  def change
    # Rename integration_type columns to descriptive names
    rename_column :interface_with_other_systems, :integration_type1, :bms_connection
    rename_column :interface_with_other_systems, :integration_type2, :elevator_control_system
    rename_column :interface_with_other_systems, :integration_type3, :fire_suppression_system
    rename_column :interface_with_other_systems, :integration_type4, :staircase_pressurization_system
    rename_column :interface_with_other_systems, :integration_type5, :hvac_system
    rename_column :interface_with_other_systems, :integration_type6, :cctv_system
    rename_column :interface_with_other_systems, :integration_type7, :access_control_system
    rename_column :interface_with_other_systems, :integration_type8, :pa_va_system
    rename_column :interface_with_other_systems, :integration_type9, :lighting_control_system
    rename_column :interface_with_other_systems, :integration_type10, :electrical_panels

    # Add cost fields for the summary numbers
    change_table :interface_with_other_systems do |t|
      # For total_no_of_control_modules
      t.integer :total_no_of_control_modules_unit_rate
      t.integer :total_no_of_control_modules_amount
      t.text    :total_no_of_control_modules_notes

      # For total_no_of_monitor_modules
      t.integer :total_no_of_monitor_modules_unit_rate
      t.integer :total_no_of_monitor_modules_amount
      t.text    :total_no_of_monitor_modules_notes

      # For total_no_of_dual_monitor_modules
      t.integer :total_no_of_dual_monitor_modules_unit_rate
      t.integer :total_no_of_dual_monitor_modules_amount
      t.text    :total_no_of_dual_monitor_modules_notes

      # For total_no_of_zone_module
      t.integer :total_no_of_zone_module_unit_rate
      t.integer :total_no_of_zone_module_amount
      t.text    :total_no_of_zone_module_notes
    end
  end
end
