class CreateFireAlarmControlPanels < ActiveRecord::Migration[7.1]
  def change
    create_table :fire_alarm_control_panels do |t|
      t.string :mfacp
      t.string :standards
      t.integer :total_no_of_panels
      t.integer :total_number_of_loop_cards
      t.integer :total_number_of_circuits_per_card_loop
      t.integer :total_no_of_loops
      t.integer :total_no_of_spare_loops
      t.integer :total_no_of_detectors_per_loop
      t.integer :spare_no_of_loops_per_panel
      t.string :initiating_devices_polarity_insensitivity
      t.float :spare_percentage_per_loop
      t.integer :fa_repeater
      t.integer :auto_dialer
      t.integer :dot_matrix_printer
      t.string :printer_listing
      t.string :backup_time
      t.string :power_standby_24_alarm_5
      t.string :power_standby_24_alarm_15
      t.integer :internal_batteries_backup_capacity_panel
      t.integer :external_batteries_backup_time

      t.timestamps
    end
  end
end
