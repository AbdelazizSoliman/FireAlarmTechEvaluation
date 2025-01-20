class AddFieldsToDetectorsFieldDevices < ActiveRecord::Migration[7.0]
  def change
    change_table :detectors_field_devices, bulk: true do |t|
      t.integer :smoke_detectors, comment: "Smoke Detectors: Basic type of detectors"
      t.integer :smoke_detectors_with_built_in_isolator, comment: "Smoke Detectors with Built-in Isolator"
      t.integer :smoke_detectors_wall_mounted_with_built_in_isolator, comment: "Wall-mounted Smoke Detectors with Built-in Isolator"
      t.integer :smoke_detectors_with_led_indicators, comment: "Smoke Detectors with LED Indicators above False Ceiling"
      t.integer :smoke_detectors_with_led_and_built_in_isolator, comment: "Smoke Detectors with LED Indicators and Built-in Isolator above False Ceiling"
      t.integer :heat_detector, comment: "Heat Detectors: Detect heat for fire safety"
      t.integer :heat_detectors_with_built_in_isolator, comment: "Heat Detectors with Built-in Isolator"
      t.integer :high_temperature_heat_detector, comment: "High-Temperature Heat Detectors for industrial use"
      t.integer :heat_rate_of_rise, comment: "Heat Detectors with Rate of Rise functionality"
      t.integer :multi_detectors, comment: "Multi-criteria Detectors for fire safety"
      t.integer :multi_detectors_with_built_in_isolator, comment: "Multi-criteria Detectors with Built-in Isolator"
      t.integer :high_sensitive_detectors_for_harsh, comment: "High-sensitive Detectors for harsh environments"
      t.integer :sensitivity_range, comment: "Sensitivity Range: Configurable range for detectors"
      t.integer :beam_detector_transmitter, comment: "Beam Detector Transmitter"
      t.integer :beam_detector_receiver, comment: "Beam Detector Receiver"
      t.integer :duct_smoke_detectors, comment: "Duct Smoke Detectors for HVAC systems"
      t.integer :flow_switches_interface_module, comment: "Flow Switches Interface Module"
      t.integer :tamper_switches_interface_module, comment: "Tamper Switches Interface Module"
      t.integer :gas_detectors, comment: "Gas Detectors for detecting combustible gases"
      t.integer :flame_detectors, comment: "Flame Detectors for early fire detection"

      # Adding Unit Rate and Amount columns for each integer column
      t.decimal :unit_rate_smoke_detectors, precision: 10, scale: 2, comment: "Unit Rate for Smoke Detectors"
      t.decimal :amount_smoke_detectors, precision: 15, scale: 2, comment: "Total Amount for Smoke Detectors (calculated as Value * Unit Rate)"
      
      # Repeat for other fields...
    end
  end
end
