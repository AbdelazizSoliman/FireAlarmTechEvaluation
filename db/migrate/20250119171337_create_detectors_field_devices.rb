class CreateDetectorsFieldDevices < ActiveRecord::Migration[7.1]
  def change
    create_table :detectors_field_devices do |t|

      t.timestamps
    end
  end
end
