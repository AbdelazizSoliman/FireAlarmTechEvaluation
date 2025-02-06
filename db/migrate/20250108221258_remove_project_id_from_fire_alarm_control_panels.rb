class RemoveProjectIdFromFireAlarmControlPanels < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:fire_alarm_control_panels, :project_id)
      remove_column :fire_alarm_control_panels, :project_id
    else
      say "Column project_id does not exist on fire_alarm_control_panels. Skipping removal."
    end
  end
end
