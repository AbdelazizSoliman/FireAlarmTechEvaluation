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

ActiveRecord::Schema[7.1].define(version: 2025_01_12_135320) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "notifications", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.boolean "read"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
  end

  create_table "project_scopes", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_scopes_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects_suppliers", id: false, force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "supplier_id", null: false
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
  end

  create_table "systems", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_scope_id", null: false
    t.index ["project_id"], name: "index_systems_on_project_id"
    t.index ["project_scope_id"], name: "index_systems_on_project_scope_id"
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

  add_foreign_key "fire_alarm_control_panels", "subsystems"
  add_foreign_key "project_scopes", "projects"
  add_foreign_key "subsystem_suppliers", "subsystems"
  add_foreign_key "subsystem_suppliers", "suppliers"
  add_foreign_key "subsystems", "systems"
  add_foreign_key "systems", "project_scopes"
  add_foreign_key "systems", "projects"
end
