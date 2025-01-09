class RemoveMfacpFromFireAlarmControlPanels < ActiveRecord::Migration[7.1]
  def change
    remove_column :fire_alarm_control_panels, :mfacp, :string
  end
end
