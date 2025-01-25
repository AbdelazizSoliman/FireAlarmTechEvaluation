class CreateIsolations < ActiveRecord::Migration[7.1]
  def change
    create_table :isolations do |t|
      t.integer :built_in_fault_isolator_for_each_detector
      t.integer :built_in_fault_isolator_for_each_mcp_bg
      t.integer :built_in_fault_isolator_for_each_sounder_horn
      t.integer :built_in_fault_isolator_for_monitor_control_modules
      t.integer :grouping_for_each_12_15
      t.references :subsystem, null: false, foreign_key: true
      t.timestamps
    end
  end
end
