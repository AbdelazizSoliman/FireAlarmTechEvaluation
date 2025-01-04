class AddProjectIdToAssociatedModels < ActiveRecord::Migration[6.1]
  def change
    add_reference :products, :project, foreign_key: true
    add_reference :fire_alarm_control_panels, :project, foreign_key: true
    add_reference :graphic_systems, :project, foreign_key: true
  end
end
