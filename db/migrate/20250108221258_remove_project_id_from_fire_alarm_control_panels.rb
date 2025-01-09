class RemoveProjectIdFromFireAlarmControlPanels < ActiveRecord::Migration[7.1]
  def change
    remove_reference :fire_alarm_control_panels, :project, null: false, foreign_key: true
  end
end
