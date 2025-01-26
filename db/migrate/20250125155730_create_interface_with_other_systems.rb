class CreateInterfaceWithOtherSystems < ActiveRecord::Migration[7.1]
  def change
    create_table :interface_with_other_systems do |t|
      t.string :integration_type1
      t.string :integration_type2
      t.string :integration_type3
      t.string :integration_type4
      t.string :integration_type5
      t.string :integration_type6
      t.string :integration_type7
      t.string :integration_type8
      t.string :integration_type9
      t.string :integration_type10
      t.integer :total_no_of_control_modules
      t.integer :total_no_of_monitor_modules
      t.integer :total_no_of_dual_monitor_modules
      t.integer :total_no_of_zone_module
      t.references :subsystem, null: false, foreign_key: true

      t.timestamps
    end
  end
end
