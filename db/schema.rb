# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_02_01_151157) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "connection_betweens", force: :cascade do |t|
    t.string "connection_type"
    t.string "network_module"
    t.string "cables_for_connection"
    t.bigint "subsystem_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subsystem_id"], name: "index_connection_betweens_on_subsystem_id"
  end

  create_table "detectors_field_devices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "subsystem_id", null: false
    t.integer "smoke_detectors", comment: "Smoke Detectors: Basic type of detectors"
    t.integer "smoke_detectors_with_built_in_isolator", comment: "Smoke Detectors with Built-in Isolator"
    t.integer "smoke_detectors_wall_mounted_with_built_in_isolator", comment: "Wall-mounted Smoke Detectors with Built-in Isolator"
    t.integer "smoke_detectors_with_led_indicators", comment: "Smoke Detectors with LED Indicators above False Ceiling"
    t.integer "smoke_detectors_with_led_and_built_in_isolator", comment: "Smoke Detectors with LED Indicators and Built-in Isolator above False Ceiling"
    t.integer "heat_detector", comment: "Heat Detectors: Detect heat for fire safety"
    t.integer "heat_detectors_with_built_in_isolator", comment: "Heat Detectors with Built-in Isolator"
    t.integer "high_temperature_heat_detector", comment: "High-Temperature Heat Detectors for industrial use"
    t.integer "heat_rate_of_rise", comment: "Heat Detectors with Rate of Rise functionality"
    t.integer "multi_detectors", comment: "Multi-criteria Detectors for fire safety"
    t.integer "multi_detectors_with_built_in_isolator", comment: "Multi-criteria Detectors with Built-in Isolator"
    t.integer "high_sensitive_detectors_for_harsh_environments", comment: "High-sensitive Detectors for harsh environments"
    t.integer "sensitivity_range", comment: "Sensitivity Range: Configurable range for detectors"
    t.integer "beam_detector_transmitter", comment: "Beam Detector Transmitter"
    t.integer "beam_detector_receiver", comment: "Beam Detector Receiver"
    t.integer "duct_smoke_detectors", comment: "Duct Smoke Detectors for HVAC systems"
    t.integer "flow_switches_interface_module", comment: "Flow Switches Interface Module"
    t.integer "tamper_switches_interface_module", comment: "Tamper Switches Interface Module"
    t.integer "gas_detectors", comment: "Gas Detectors for detecting combustible gases"
    t.integer "flame_detectors", comment: "Flame Detectors for early fire detection"
    t.decimal "unit_rate_smoke_detectors", precision: 10, scale: 2, comment: "Unit Rate for Smoke Detectors"
    t.decimal "amount_smoke_detectors", precision: 15, scale: 2, comment: "Total Amount for Smoke Detectors (calculated as Value * Unit Rate)"
    t.integer "smoke_detectors_value"
    t.integer "smoke_detectors_unit_rate"
    t.integer "smoke_detectors_amount"
    t.text "smoke_detectors_notes"
    t.integer "smoke_detectors_with_built_in_isolator_value"
    t.integer "smoke_detectors_with_built_in_isolator_unit_rate"
    t.integer "smoke_detectors_with_built_in_isolator_amount"
    t.text "smoke_detectors_with_built_in_isolator_notes"
    t.integer "smoke_detectors_wall_mounted_with_built_in_isolator_value"
    t.integer "smoke_detectors_wall_mounted_with_built_in_isolator_unit_rate"
    t.integer "smoke_detectors_wall_mounted_with_built_in_isolator_amount"
    t.text "smoke_detectors_wall_mounted_with_built_in_isolator_notes"
    t.integer "smoke_detectors_with_led_indicators_value"
    t.integer "smoke_detectors_with_led_indicators_unit_rate"
    t.integer "smoke_detectors_with_led_indicators_amount"
    t.text "smoke_detectors_with_led_indicators_notes"
    t.integer "smoke_detectors_with_led_and_built_in_isolator_value"
    t.integer "smoke_detectors_with_led_and_built_in_isolator_unit_rate"
    t.integer "smoke_detectors_with_led_and_built_in_isolator_amount"
    t.text "smoke_detectors_with_led_and_built_in_isolator_notes"
    t.integer "heat_detectors_value"
    t.integer "heat_detectors_unit_rate"
    t.integer "heat_detectors_amount"
    t.text "heat_detectors_notes"
    t.integer "heat_detectors_with_built_in_isolator_value"
    t.integer "heat_detectors_with_built_in_isolator_unit_rate"
    t.integer "heat_detectors_with_built_in_isolator_amount"
    t.text "heat_detectors_with_built_in_isolator_notes"
    t.integer "high_temperature_heat_detectors_value"
    t.integer "high_temperature_heat_detectors_unit_rate"
    t.integer "high_temperature_heat_detectors_amount"
    t.text "high_temperature_heat_detectors_notes"
    t.integer "heat_rate_of_rise_value"
    t.integer "heat_rate_of_rise_unit_rate"
    t.integer "heat_rate_of_rise_amount"
    t.text "heat_rate_of_rise_notes"
    t.integer "multi_detectors_value"
    t.integer "multi_detectors_unit_rate"
    t.integer "multi_detectors_amount"
    t.text "multi_detectors_notes"
    t.integer "multi_detectors_with_built_in_isolator_value"
    t.integer "multi_detectors_with_built_in_isolator_unit_rate"
    t.integer "multi_detectors_with_built_in_isolator_amount"
    t.text "multi_detectors_with_built_in_isolator_notes"
    t.integer "high_sensitive_detectors_for_harsh_environments_value"
    t.integer "high_sensitive_detectors_for_harsh_environments_unit_rate"
    t.integer "high_sensitive_detectors_for_harsh_environments_amount"
    t.text "high_sensitive_detectors_for_harsh_environments_notes"
    t.integer "sensitivity_range_value"
    t.integer "sensitivity_range_unit_rate"
    t.integer "sensitivity_range_amount"
    t.text "sensitivity_range_notes"
    t.integer "beam_detector_transmitter_value"
    t.integer "beam_detector_transmitter_unit_rate"
    t.integer "beam_detector_transmitter_amount"
    t.text "beam_detector_transmitter_notes"
    t.integer "beam_detector_receiver_value"
    t.integer "beam_detector_receiver_unit_rate"
    t.integer "beam_detector_receiver_amount"
    t.text "beam_detector_receiver_notes"
    t.integer "duct_smoke_detectors_value"
    t.integer "duct_smoke_detectors_unit_rate"
    t.integer "duct_smoke_detectors_amount"
    t.text "duct_smoke_detectors_notes"
    t.integer "flow_switches_interface_module_value"
    t.integer "flow_switches_interface_module_unit_rate"
    t.integer "flow_switches_interface_module_amount"
    t.text "flow_switches_interface_module_notes"
    t.integer "tamper_switches_interface_module_value"
    t.integer "tamper_switches_interface_module_unit_rate"
    t.integer "tamper_switches_interface_module_amount"
    t.text "tamper_switches_interface_module_notes"
    t.integer "gas_detectors_value"
    t.integer "gas_detectors_unit_rate"
    t.integer "gas_detectors_amount"
    t.text "gas_detectors_notes"
    t.integer "flame_detectors_value"
    t.integer "flame_detectors_unit_rate"
    t.integer "flame_detectors_amount"
    t.text "flame_detectors_notes"
    t.index ["subsystem_id"], name: "index_detectors_field_devices_on_subsystem_id"
  end

  create_table "door_holders", force: :cascade do |t|
    t.integer "total_no_of_devices"
    t.integer "total_no_of_devices_unit_rate"
    t.integer "total_no_of_devices_amount"
    t.text "total_no_of_devices_notes"
    t.integer "total_no_of_relays"
    t.integer "total_no_of_relays_unit_rate"
    t.integer "total_no_of_relays_amount"
    t.text "total_no_of_relays_notes"
    t.bigint "subsystem_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subsystem_id"], name: "index_door_holders_on_subsystem_id"
  end

  create_table "evacuation_systems", force: :cascade do |t|
    t.string "included_in_fire_alarm_system"
    t.string "evacuation_system_part_of_fa_panel"
    t.integer "amplifier_power_output"
    t.integer "total_no_of_amplifiers"
    t.integer "total_no_of_evacuation_speakers_circuits"
    t.integer "total_no_of_wattage_per_panel"
    t.decimal "fire_rated_speakers_watt"
    t.decimal "speakers_tapping_watt"
    t.integer "total_no_of_speakers"
    t.bigint "subsystem_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subsystem_id"], name: "index_evacuation_systems_on_subsystem_id"
  end

  create_table "fire_alarm_control_panels", force: :cascade do |t|
    t.string "standards"
    t.integer "total_no_of_panels"
    t.integer "total_number_of_loop_cards"
    t.integer "total_number_of_circuits_per_card_loop"
    t.integer "total_no_of_loops"
    t.integer "total_no_of_spare_loops"
    t.integer "total_no_of_detectors_per_loop"
    t.integer "spare_no_of_loops_per_panel"
    t.string "initiating_devices_polarity_insensitivity"
    t.integer "spare_percentage_per_loop"
    t.integer "fa_repeater"
    t.integer "auto_dialer"
    t.integer "dot_matrix_printer"
    t.string "printer_listing"
    t.string "power_standby_24_alarm_5"
    t.string "power_standby_24_alarm_15"
    t.integer "internal_batteries_backup_capacity_panel"
    t.integer "external_batteries_backup_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "subsystem_id", null: false
    t.index ["subsystem_id"], name: "index_fire_alarm_control_panels_on_subsystem_id"
  end

  create_table "general_commercial_data", force: :cascade do |t|
    t.integer "warranty_for_materials"
    t.integer "warranty_for_configuration_programming"
    t.integer "support_and_maintenance"
    t.integer "spare_parts_availability"
    t.integer "advanced_payment_minimum"
    t.integer "performance_bond"
    t.decimal "total_price_excluding_vat"
    t.bigint "subsystem_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subsystem_id"], name: "index_general_commercial_data_on_subsystem_id"
  end

  create_table "graphic_systems", force: :cascade do |t|
    t.string "workstation"
    t.string "workstation_control_feature"
    t.string "softwares"
    t.string "licenses"
    t.string "screens"
    t.bigint "subsystem_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subsystem_id"], name: "index_graphic_systems_on_subsystem_id"
  end

  create_table "interface_with_other_systems", force: :cascade do |t|
    t.string "integration_type1"
    t.string "integration_type2"
    t.string "integration_type3"
    t.string "integration_type4"
    t.string "integration_type5"
    t.string "integration_type6"
    t.string "integration_type7"
    t.string "integration_type8"
    t.string "integration_type9"
    t.string "integration_type10"
    t.integer "total_no_of_control_modules"
    t.integer "total_no_of_monitor_modules"
    t.integer "total_no_of_dual_monitor_modules"
    t.integer "total_no_of_zone_module"
    t.bigint "subsystem_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subsystem_id"], name: "index_interface_with_other_systems_on_subsystem_id"
  end

  create_table "isolations", force: :cascade do |t|
    t.integer "built_in_fault_isolator_for_each_detector"
    t.integer "built_in_fault_isolator_for_each_mcp_bg"
    t.integer "built_in_fault_isolator_for_each_sounder_horn"
    t.integer "built_in_fault_isolator_for_monitor_control_modules"
    t.integer "grouping_for_each_12_15"
    t.bigint "subsystem_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subsystem_id"], name: "index_isolations_on_subsystem_id"
  end

  create_table "manual_pull_stations", force: :cascade do |t|
    t.string "type"
    t.integer "break_glass"
    t.integer "break_glass_weather_proof"
    t.bigint "subsystem_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subsystem_id"], name: "index_manual_pull_stations_on_subsystem_id"
  end

  create_table "material_and_deliveries", force: :cascade do |t|
    t.string "material_availability"
    t.string "delivery_time_period"
    t.string "delivery_type"
    t.string "delivery_to"
    t.bigint "subsystem_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subsystem_id"], name: "index_material_and_deliveries_on_subsystem_id"
  end

  create_table "notification_devices", force: :cascade do |t|
    t.string "notification_addressing"
    t.integer "fire_alarm_strobe"
    t.integer "fire_alarm_strobe_wp"
    t.integer "fire_alarm_horn"
    t.integer "fire_alarm_horn_wp"
    t.integer "fire_alarm_horn_with_strobe"
    t.integer "fire_alarm_horn_with_strobe_wp"
    t.bigint "subsystem_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subsystem_id"], name: "index_notification_devices_on_subsystem_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.boolean "read"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notification_type"
    t.text "additional_data"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
  end

  create_table "prerecorded_message_audio_modules", force: :cascade do |t|
    t.string "message_type"
    t.integer "total_time_for_messages"
    t.integer "total_no_of_voice_messages"
    t.string "message_storage_location"
    t.string "master_microphone"
    t.bigint "subsystem_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subsystem_id"], name: "index_prerecorded_message_audio_modules_on_subsystem_id"
  end

  create_table "product_data", force: :cascade do |t|
    t.string "manufacturer"
    t.string "submitted_product"
    t.string "product_certifications"
    t.integer "total_years_in_saudi_market"
    t.string "coo"
    t.string "com_for_mfacp"
    t.string "com_for_detectors"
    t.bigint "subsystem_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subsystem_id"], name: "index_product_data_on_subsystem_id"
  end

  create_table "project_scopes", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_scopes_on_project_id"
  end

  create_table "project_scopes_suppliers", id: false, force: :cascade do |t|
    t.bigint "project_scope_id", null: false
    t.bigint "supplier_id", null: false
    t.index ["project_scope_id", "supplier_id"], name: "idx_on_project_scope_id_supplier_id_16938ca3e1"
    t.index ["supplier_id", "project_scope_id"], name: "idx_on_supplier_id_project_scope_id_95e8d35df4"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects_suppliers", id: false, force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "supplier_id", null: false
    t.boolean "approved", default: false, null: false
    t.index ["project_id", "supplier_id"], name: "index_projects_suppliers_on_project_id_and_supplier_id", unique: true
    t.index ["supplier_id", "project_id"], name: "index_projects_suppliers_on_supplier_id_and_project_id"
  end

  create_table "scope_of_works", force: :cascade do |t|
    t.string "supply"
    t.string "install"
    t.string "supervision_test_commissioning"
    t.string "cables_supply"
    t.integer "cables_size_2cx1_5mm"
    t.integer "cables_size_2cx2_5mm"
    t.string "pulling_cables"
    t.string "cables_terminations"
    t.string "design_review_verification"
    t.string "heat_map_study"
    t.string "voltage_drop_study_for_initiating_devices_loop"
    t.string "voltage_drop_notification_circuits"
    t.string "battery_calculation"
    t.string "cause_and_effect_matrix"
    t.string "high_level_riser_diagram"
    t.string "shop_drawings"
    t.string "shop_drawings_verification"
    t.integer "training_days"
    t.bigint "subsystem_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subsystem_id"], name: "index_scope_of_works_on_subsystem_id"
  end

  create_table "spare_parts", force: :cascade do |t|
    t.integer "total_no_of_device1"
    t.integer "total_no_of_device2"
    t.integer "total_no_of_device3"
    t.integer "total_no_of_device4"
    t.bigint "subsystem_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subsystem_id"], name: "index_spare_parts_on_subsystem_id"
  end

  create_table "subsystem_suppliers", force: :cascade do |t|
    t.bigint "subsystem_id", null: false
    t.bigint "supplier_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subsystem_id"], name: "index_subsystem_suppliers_on_subsystem_id"
    t.index ["supplier_id"], name: "index_subsystem_suppliers_on_supplier_id"
  end

  create_table "subsystems", force: :cascade do |t|
    t.bigint "system_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["system_id"], name: "index_subsystems_on_system_id"
  end

  create_table "subsystems_suppliers", id: false, force: :cascade do |t|
    t.bigint "subsystem_id", null: false
    t.bigint "supplier_id", null: false
    t.boolean "approved", default: false, null: false
    t.index ["subsystem_id", "supplier_id"], name: "index_subsystems_suppliers_on_subsystem_id_and_supplier_id", unique: true
    t.index ["supplier_id", "subsystem_id"], name: "index_subsystems_suppliers_on_supplier_id_and_subsystem_id"
  end

  create_table "supplier_data", force: :cascade do |t|
    t.string "supplier_name", null: false, comment: "The name of the supplier"
    t.string "supplier_category", null: false, comment: "The category or type of the supplier"
    t.integer "total_years_in_saudi_market", null: false, comment: "The total number of years the supplier has been active in the Saudi market"
    t.text "similar_projects", comment: "Details of similar projects carried out (mention 3 projects)"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "subsystem_id", null: false
    t.index ["subsystem_id"], name: "index_supplier_data_on_subsystem_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "supplier_name"
    t.string "supplier_category"
    t.integer "total_years_in_saudi_market"
    t.string "phone"
    t.string "supplier_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "password_digest"
    t.string "status"
    t.string "membership_type"
    t.boolean "receive_evaluation_report"
    t.string "registration_type", default: "evaluation", null: false
    t.string "evaluation_type"
    t.string "purpose"
  end

  create_table "systems", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_scope_id", null: false
    t.index ["project_scope_id"], name: "index_systems_on_project_scope_id"
  end

  create_table "systems_suppliers", id: false, force: :cascade do |t|
    t.bigint "system_id", null: false
    t.bigint "supplier_id", null: false
    t.index ["supplier_id", "system_id"], name: "index_systems_suppliers_on_supplier_id_and_system_id"
    t.index ["system_id", "supplier_id"], name: "index_systems_suppliers_on_system_id_and_supplier_id", unique: true
  end

  create_table "telephone_systems", force: :cascade do |t|
    t.integer "number_of_firefighter_telephone_circuits_per_panel"
    t.integer "total_no_of_firefighter_telephone_cabinet"
    t.integer "total_no_of_firefighter_phones"
    t.integer "total_no_of_firefighter_jacks"
    t.bigint "subsystem_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subsystem_id"], name: "index_telephone_systems_on_subsystem_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "connection_betweens", "subsystems"
  add_foreign_key "detectors_field_devices", "subsystems"
  add_foreign_key "door_holders", "subsystems"
  add_foreign_key "evacuation_systems", "subsystems"
  add_foreign_key "fire_alarm_control_panels", "subsystems"
  add_foreign_key "general_commercial_data", "subsystems"
  add_foreign_key "graphic_systems", "subsystems"
  add_foreign_key "interface_with_other_systems", "subsystems"
  add_foreign_key "isolations", "subsystems"
  add_foreign_key "manual_pull_stations", "subsystems"
  add_foreign_key "material_and_deliveries", "subsystems"
  add_foreign_key "notification_devices", "subsystems"
  add_foreign_key "prerecorded_message_audio_modules", "subsystems"
  add_foreign_key "product_data", "subsystems"
  add_foreign_key "project_scopes", "projects"
  add_foreign_key "scope_of_works", "subsystems"
  add_foreign_key "spare_parts", "subsystems"
  add_foreign_key "subsystem_suppliers", "subsystems"
  add_foreign_key "subsystem_suppliers", "suppliers"
  add_foreign_key "subsystems", "systems"
  add_foreign_key "supplier_data", "subsystems"
  add_foreign_key "systems", "project_scopes"
  add_foreign_key "systems_suppliers", "suppliers"
  add_foreign_key "systems_suppliers", "systems"
  add_foreign_key "telephone_systems", "subsystems"
end
