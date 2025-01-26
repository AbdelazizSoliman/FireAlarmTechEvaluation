class CreateScopeOfWorks < ActiveRecord::Migration[7.1]
  def change
    create_table :scope_of_works do |t|
      t.string :supply
      t.string :install
      t.string :supervision_test_commissioning
      t.string :cables_supply
      t.integer :cables_size_2cx1_5mm
      t.integer :cables_size_2cx2_5mm
      t.string :pulling_cables
      t.string :cables_terminations
      t.string :design_review_verification
      t.string :heat_map_study
      t.string :voltage_drop_study_for_initiating_devices_loop
      t.string :voltage_drop_notification_circuits
      t.string :battery_calculation
      t.string :cause_and_effect_matrix
      t.string :high_level_riser_diagram
      t.string :shop_drawings
      t.string :shop_drawings_verification
      t.integer :training_days
      t.references :subsystem, null: false, foreign_key: true

      t.timestamps
    end
  end
end
