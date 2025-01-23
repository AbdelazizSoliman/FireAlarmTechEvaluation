class FixHighSensitiveDetectorsColumn < ActiveRecord::Migration[7.1]
  def change
    rename_column :detectors_field_devices, :high_sensitive_detectors_for_harsh, :high_sensitive_detectors_for_harsh_environments
  end
end
