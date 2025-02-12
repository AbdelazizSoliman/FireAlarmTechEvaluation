class RemoveMfacpFromFireAlarmControlPanels < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:fire_alarm_control_panels, :mfacp)
      remove_column :fire_alarm_control_panels, :mfacp, :string
    end
  end
end