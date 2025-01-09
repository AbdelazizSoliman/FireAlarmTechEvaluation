# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Create a project
project = Project.create!(name: "Almahdy Hospital")

# Create a system
system = System.create!(name: "Light Current", project: project)

# Create a subsystem
subsystem = Subsystem.create!(name: "Fire Alarm System", system: system)

# Create a fire alarm control panel
FireAlarmControlPanel.create!(
  project: project,
  mfacp: "Brand XYZ",
  standards: "UL Listed",
  total_no_of_panels: 10,
  total_number_of_loop_cards: 20,
  total_number_of_circuits_per_card_loop: 4,
  total_no_of_loops: 40,
  total_no_of_spare_loops: 5,
  total_no_of_detectors_per_loop: 200,
  spare_no_of_loops_per_panel: 2,
  initiating_devices_polarity_insensitivity: "Yes",
  spare_percentage_per_loop: 10,
  fa_repeater: 3,
  auto_dialer: 1,
  dot_matrix_printer: 1,
  printer_listing: "UL",
  power_standby_24_alarm_5: "Yes",
  power_standby_24_alarm_15: "Yes",
  internal_batteries_backup_capacity_panel: 2,
  external_batteries_backup_time: 4
)

