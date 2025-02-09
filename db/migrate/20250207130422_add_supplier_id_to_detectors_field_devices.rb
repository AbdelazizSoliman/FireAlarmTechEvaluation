class AddSupplierIdToDetectorsFieldDevices < ActiveRecord::Migration[7.1]
  def change
    add_reference :detectors_field_devices, :supplier, null: false, foreign_key: true
  end
end
