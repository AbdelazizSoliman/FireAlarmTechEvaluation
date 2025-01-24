class CreateNotificationDevices < ActiveRecord::Migration[7.1]
  def change
    create_table :notification_devices do |t|
      t.string :notification_addressing
      t.integer :fire_alarm_strobe
      t.integer :fire_alarm_strobe_wp
      t.integer :fire_alarm_horn
      t.integer :fire_alarm_horn_wp
      t.integer :fire_alarm_horn_with_strobe
      t.integer :fire_alarm_horn_with_strobe_wp
      t.references :subsystem, null: false, foreign_key: true

      t.timestamps
    end
  end
end
