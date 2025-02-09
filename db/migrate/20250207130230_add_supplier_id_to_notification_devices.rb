class AddSupplierIdToNotificationDevices < ActiveRecord::Migration[7.1]
  def change
    add_reference :notification_devices, :supplier, null: false, foreign_key: true
  end
end
