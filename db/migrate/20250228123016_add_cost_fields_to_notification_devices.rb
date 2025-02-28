class AddCostFieldsToNotificationDevices < ActiveRecord::Migration[7.1]
  def change
    change_table :notification_devices do |t|
      t.integer :fire_alarm_strobe_unit_rate
      t.integer :fire_alarm_strobe_amount
      t.text    :fire_alarm_strobe_notes

      t.integer :fire_alarm_strobe_wp_unit_rate
      t.integer :fire_alarm_strobe_wp_amount
      t.text    :fire_alarm_strobe_wp_notes

      t.integer :fire_alarm_horn_unit_rate
      t.integer :fire_alarm_horn_amount
      t.text    :fire_alarm_horn_notes

      t.integer :fire_alarm_horn_wp_unit_rate
      t.integer :fire_alarm_horn_wp_amount
      t.text    :fire_alarm_horn_wp_notes

      t.integer :fire_alarm_horn_with_strobe_unit_rate
      t.integer :fire_alarm_horn_with_strobe_amount
      t.text    :fire_alarm_horn_with_strobe_notes

      t.integer :fire_alarm_horn_with_strobe_wp_unit_rate
      t.integer :fire_alarm_horn_with_strobe_wp_amount
      t.text    :fire_alarm_horn_with_strobe_wp_notes
    end
  end
end
