class AddSubsystemIdToDetectorsFieldDevices < ActiveRecord::Migration[7.0]
  def change
    add_reference :detectors_field_devices, :subsystem, null: false, foreign_key: true
  end
end
