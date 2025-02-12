class RemoveProjectIdFromFireAlarmControlPanels < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:fire_alarm_control_panels, :project_id)
      remove_reference :fire_alarm_control_panels, :project, null: false, foreign_key: true
    end
end
