class FixHighSensitiveDetectorsColumn < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:detectors_field_devices, :high_sensitive_detectors_for_harsh)
      rename_column :detectors_field_devices, :high_sensitive_detectors_for_harsh, :high_sensitive_detectors_for_harsh_environments
    else
      say "Column high_sensitive_detectors_for_harsh does not exist on detectors_field_devices. Skipping rename."
    end
  end
end
