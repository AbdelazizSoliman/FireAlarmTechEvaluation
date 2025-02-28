class AddCostFieldsToIsolations < ActiveRecord::Migration[7.1]
  def change
    change_table :isolations do |t|
      # For built_in_fault_isolator_for_each_detector
      t.integer :built_in_fault_isolator_for_each_detector_unit_rate
      t.integer :built_in_fault_isolator_for_each_detector_amount
      t.text    :built_in_fault_isolator_for_each_detector_notes

      # For built_in_fault_isolator_for_each_mcp_bg
      t.integer :built_in_fault_isolator_for_each_mcp_bg_unit_rate
      t.integer :built_in_fault_isolator_for_each_mcp_bg_amount
      t.text    :built_in_fault_isolator_for_each_mcp_bg_notes

      # For built_in_fault_isolator_for_each_sounder_horn
      t.integer :built_in_fault_isolator_for_each_sounder_horn_unit_rate
      t.integer :built_in_fault_isolator_for_each_sounder_horn_amount
      t.text    :built_in_fault_isolator_for_each_sounder_horn_notes

      # For built_in_fault_isolator_for_monitor_control_modules
      t.integer :built_in_fault_isolator_for_monitor_control_modules_unit_rate
      t.integer :built_in_fault_isolator_for_monitor_control_modules_amount
      t.text    :built_in_fault_isolator_for_monitor_control_modules_notes

      # For grouping_for_each_12_15
      t.integer :grouping_for_each_12_15_unit_rate
      t.integer :grouping_for_each_12_15_amount
      t.text    :grouping_for_each_12_15_notes
    end
  end
end
