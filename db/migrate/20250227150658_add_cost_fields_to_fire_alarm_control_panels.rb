class AddCostFieldsToFireAlarmControlPanels < ActiveRecord::Migration[7.1]
  def change
    change_table :fire_alarm_control_panels do |t|
      # For total_no_of_panels
      t.integer :total_no_of_panels_unit_rate
      t.integer :total_no_of_panels_amount
      t.text    :total_no_of_panels_notes

      # For total_number_of_loop_cards
      t.integer :total_number_of_loop_cards_unit_rate
      t.integer :total_number_of_loop_cards_amount
      t.text    :total_number_of_loop_cards_notes

      # For total_number_of_circuits_per_card_loop
      t.integer :total_number_of_circuits_per_card_loop_unit_rate
      t.integer :total_number_of_circuits_per_card_loop_amount
      t.text    :total_number_of_circuits_per_card_loop_notes

      # For total_no_of_loops
      t.integer :total_no_of_loops_unit_rate
      t.integer :total_no_of_loops_amount
      t.text    :total_no_of_loops_notes

      # For total_no_of_spare_loops
      t.integer :total_no_of_spare_loops_unit_rate
      t.integer :total_no_of_spare_loops_amount
      t.text    :total_no_of_spare_loops_notes

      # For total_no_of_detectors_per_loop
      t.integer :total_no_of_detectors_per_loop_unit_rate
      t.integer :total_no_of_detectors_per_loop_amount
      t.text    :total_no_of_detectors_per_loop_notes

      # For spare_no_of_loops_per_panel
      t.integer :spare_no_of_loops_per_panel_unit_rate
      t.integer :spare_no_of_loops_per_panel_amount
      t.text    :spare_no_of_loops_per_panel_notes

      # For spare_percentage_per_loop
      t.integer :spare_percentage_per_loop_unit_rate
      t.integer :spare_percentage_per_loop_amount
      t.text    :spare_percentage_per_loop_notes

      # For fa_repeater
      t.integer :fa_repeater_unit_rate
      t.integer :fa_repeater_amount
      t.text    :fa_repeater_notes

      # For auto_dialer
      t.integer :auto_dialer_unit_rate
      t.integer :auto_dialer_amount
      t.text    :auto_dialer_notes

      # For dot_matrix_printer
      t.integer :dot_matrix_printer_unit_rate
      t.integer :dot_matrix_printer_amount
      t.text    :dot_matrix_printer_notes

      # For internal_batteries_backup_capacity_panel
      t.integer :internal_batteries_backup_capacity_panel_unit_rate
      t.integer :internal_batteries_backup_capacity_panel_amount
      t.text    :internal_batteries_backup_capacity_panel_notes

      # For external_batteries_backup_time
      t.integer :external_batteries_backup_time_unit_rate
      t.integer :external_batteries_backup_time_amount
      t.text    :external_batteries_backup_time_notes
    end
  end
end
