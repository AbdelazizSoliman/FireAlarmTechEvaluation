class AddFieldsToDetectorsFieldDevices < ActiveRecord::Migration[7.1]
  def change
    add_column :detectors_field_devices, :value, :integer
    add_column :detectors_field_devices, :unit_rate, :integer
    add_column :detectors_field_devices, :amount, :integer
    add_column :detectors_field_devices, :notes, :text
  end
end
