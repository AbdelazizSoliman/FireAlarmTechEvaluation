class AddAdditionalDataToNotifications < ActiveRecord::Migration[7.1]
  def change
    add_column :notifications, :additional_data, :text
  end
end
