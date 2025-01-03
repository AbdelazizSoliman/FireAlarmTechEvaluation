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

ActiveRecord::Schema[7.1].define(version: 2025_01_03_224700) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "fire_alarm_control_panels", force: :cascade do |t|
    t.string "mfacp"
    t.string "standards"
    t.integer "total_no_of_panels"
    t.integer "total_number_of_loop_cards"
    t.integer "total_number_of_circuits_per_card_loop"
    t.integer "total_no_of_loops"
    t.integer "total_no_of_spare_loops"
    t.integer "total_no_of_detectors_per_loop"
    t.integer "spare_no_of_loops_per_panel"
    t.string "initiating_devices_polarity_insensitivity"
    t.float "spare_percentage_per_loop"
    t.integer "fa_repeater"
    t.integer "auto_dialer"
    t.integer "dot_matrix_printer"
    t.string "printer_listing"
    t.string "backup_time"
    t.string "power_standby_24_alarm_5"
    t.string "power_standby_24_alarm_15"
    t.integer "internal_batteries_backup_capacity_panel"
    t.integer "external_batteries_backup_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "graphic_systems", force: :cascade do |t|
    t.string "workstation"
    t.string "workstation_control_feature"
    t.string "softwares"
    t.integer "licenses"
    t.string "screens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "product_name"
    t.string "country_of_origin"
    t.string "country_of_manufacture_mfacp"
    t.string "country_of_manufacture_detectors"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "supplier_name"
    t.string "supplier_category"
    t.integer "total_years_in_saudi_market"
    t.string "phone"
    t.string "supplier_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

end
