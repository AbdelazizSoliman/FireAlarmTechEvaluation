class AddSupplierIdToFireAlarmControlPanels < ActiveRecord::Migration[7.1]
  def change
    add_reference :fire_alarm_control_panels, :supplier, null: false, foreign_key: true
  end
end
