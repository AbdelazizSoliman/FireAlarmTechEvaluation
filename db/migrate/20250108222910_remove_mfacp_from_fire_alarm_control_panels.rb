class RemoveMfacpFromFireAlarmControlPanels < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:fire_alarm_control_panels, :mfacp)
      remove_column :fire_alarm_control_panels, :mfacp, :string
    else
      say "Column mfacp does not exist on fire_alarm_control_panels. Skipping removal."
    end
  end
end
