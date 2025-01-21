class RestructureDetectorsFieldDevices < ActiveRecord::Migration[7.1]
  def change
    # Remove generic columns
    remove_column :detectors_field_devices, :value, :integer
    remove_column :detectors_field_devices, :unit_rate, :integer
    remove_column :detectors_field_devices, :amount, :integer
    remove_column :detectors_field_devices, :notes, :text

    # Add specific columns for each detector type
    change_table :detectors_field_devices do |t|
      # Smoke Detectors
      t.integer :smoke_detectors_value
      t.integer :smoke_detectors_unit_rate
      t.integer :smoke_detectors_amount
      t.text :smoke_detectors_notes

      # Smoke Detectors with Built-in Isolator
      t.integer :smoke_detectors_with_built_in_isolator_value
      t.integer :smoke_detectors_with_built_in_isolator_unit_rate
      t.integer :smoke_detectors_with_built_in_isolator_amount
      t.text :smoke_detectors_with_built_in_isolator_notes

      # Wall-mounted Smoke Detectors with Built-in Isolator
      t.integer :smoke_detectors_wall_mounted_with_built_in_isolator_value
      t.integer :smoke_detectors_wall_mounted_with_built_in_isolator_unit_rate
      t.integer :smoke_detectors_wall_mounted_with_built_in_isolator_amount
      t.text :smoke_detectors_wall_mounted_with_built_in_isolator_notes

      # Smoke Detectors with LED Indicators
      t.integer :smoke_detectors_with_led_indicators_value
      t.integer :smoke_detectors_with_led_indicators_unit_rate
      t.integer :smoke_detectors_with_led_indicators_amount
      t.text :smoke_detectors_with_led_indicators_notes

      # Smoke Detectors with LED and Built-in Isolator
      t.integer :smoke_detectors_with_led_and_built_in_isolator_value
      t.integer :smoke_detectors_with_led_and_built_in_isolator_unit_rate
      t.integer :smoke_detectors_with_led_and_built_in_isolator_amount
      t.text :smoke_detectors_with_led_and_built_in_isolator_notes

      # Heat Detectors
      t.integer :heat_detectors_value
      t.integer :heat_detectors_unit_rate
      t.integer :heat_detectors_amount
      t.text :heat_detectors_notes

      # Heat Detectors with Built-in Isolator
      t.integer :heat_detectors_with_built_in_isolator_value
      t.integer :heat_detectors_with_built_in_isolator_unit_rate
      t.integer :heat_detectors_with_built_in_isolator_amount
      t.text :heat_detectors_with_built_in_isolator_notes

      # High-temperature Heat Detectors
      t.integer :high_temperature_heat_detectors_value
      t.integer :high_temperature_heat_detectors_unit_rate
      t.integer :high_temperature_heat_detectors_amount
      t.text :high_temperature_heat_detectors_notes

      # Heat Rate of Rise Detectors
      t.integer :heat_rate_of_rise_value
      t.integer :heat_rate_of_rise_unit_rate
      t.integer :heat_rate_of_rise_amount
      t.text :heat_rate_of_rise_notes

      # Multi Detectors
      t.integer :multi_detectors_value
      t.integer :multi_detectors_unit_rate
      t.integer :multi_detectors_amount
      t.text :multi_detectors_notes

      # Multi Detectors with Built-in Isolator
      t.integer :multi_detectors_with_built_in_isolator_value
      t.integer :multi_detectors_with_built_in_isolator_unit_rate
      t.integer :multi_detectors_with_built_in_isolator_amount
      t.text :multi_detectors_with_built_in_isolator_notes

      # High Sensitive Detectors for Harsh Environments
      t.integer :high_sensitive_detectors_for_harsh_environments_value
      t.integer :high_sensitive_detectors_for_harsh_environments_unit_rate
      t.integer :high_sensitive_detectors_for_harsh_environments_amount
      t.text :high_sensitive_detectors_for_harsh_environments_notes

      # Sensitivity Range
      t.integer :sensitivity_range_value
      t.integer :sensitivity_range_unit_rate
      t.integer :sensitivity_range_amount
      t.text :sensitivity_range_notes

      # Beam Detector Transmitter
      t.integer :beam_detector_transmitter_value
      t.integer :beam_detector_transmitter_unit_rate
      t.integer :beam_detector_transmitter_amount
      t.text :beam_detector_transmitter_notes

      # Beam Detector Receiver
      t.integer :beam_detector_receiver_value
      t.integer :beam_detector_receiver_unit_rate
      t.integer :beam_detector_receiver_amount
      t.text :beam_detector_receiver_notes

      # Duct Smoke Detectors
      t.integer :duct_smoke_detectors_value
      t.integer :duct_smoke_detectors_unit_rate
      t.integer :duct_smoke_detectors_amount
      t.text :duct_smoke_detectors_notes

      # Flow Switches Interface Module
      t.integer :flow_switches_interface_module_value
      t.integer :flow_switches_interface_module_unit_rate
      t.integer :flow_switches_interface_module_amount
      t.text :flow_switches_interface_module_notes

      # Tamper Switches Interface Module
      t.integer :tamper_switches_interface_module_value
      t.integer :tamper_switches_interface_module_unit_rate
      t.integer :tamper_switches_interface_module_amount
      t.text :tamper_switches_interface_module_notes

      # Gas Detectors
      t.integer :gas_detectors_value
      t.integer :gas_detectors_unit_rate
      t.integer :gas_detectors_amount
      t.text :gas_detectors_notes

      # Flame Detectors
      t.integer :flame_detectors_value
      t.integer :flame_detectors_unit_rate
      t.integer :flame_detectors_amount
      t.text :flame_detectors_notes
    end
  end
end
