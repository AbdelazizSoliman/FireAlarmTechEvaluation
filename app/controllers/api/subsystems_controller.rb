module Api
    class SubsystemsController < ApplicationController
      skip_before_action :verify_authenticity_token
  
      def submit_all
        # Locate the subsystem
        subsystem = Subsystem.find(params[:id])
  
        # Extract and filter parameters using strong parameter methods
        supplier_data_params = supplier_data_params()
        fire_alarm_data = fire_alarm_control_panel_params()
        detectors_data = detectors_field_devices_params()
  
        # Create or update the supplier_data record
        supplier_data_record = subsystem.supplier_data || subsystem.build_supplier_data(supplier_data_params)
  
        # Create the fire_alarm_control_panel record
        fire_alarm_control_panel = subsystem.fire_alarm_control_panels.new(fire_alarm_data)
  
        # Create detectors_field_devices records
        detectors_field_devices = detectors_data.to_h.map do |key, attributes|
          subsystem.detectors_field_devices.new(attributes.merge(device_type: key))
        end
  
        # Use a transaction to ensure atomicity
        ActiveRecord::Base.transaction do
          # Save supplier_data
          unless supplier_data_record.save
            raise ActiveRecord::RecordInvalid.new(supplier_data_record)
          end
  
          # Save fire_alarm_control_panel
          unless fire_alarm_control_panel.save
            raise ActiveRecord::RecordInvalid.new(fire_alarm_control_panel)
          end
  
          # Save detectors_field_devices
          detectors_field_devices.each do |device|
            unless device.save
              raise ActiveRecord::RecordInvalid.new(device)
            end
          end
        end
  
        # If we reach this point, data was successfully saved
        Notification.create!(
          title: "Evaluation Submitted",
          body: "Evaluation for subsystem ##{subsystem.id} has been submitted.",
          notifiable: subsystem,
          notification_type: "evaluation",
          additional_data: { subsystem_id: subsystem.id }.to_json
        )
  
        render json: { message: "Data submitted successfully." }, status: :created
      rescue ActiveRecord::RecordInvalid => e
        # Handle any errors in saving records
        render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
      end
  

      private

      def fire_alarm_control_panel_params
        params.require(:fire_alarm_control_panel).permit(
          :standards, :total_no_of_panels, :total_number_of_loop_cards,
          :total_number_of_circuits_per_card_loop, :total_no_of_loops,
          :total_no_of_spare_loops, :total_no_of_detectors_per_loop,
          :spare_no_of_loops_per_panel, :initiating_devices_polarity_insensitivity,
          :spare_percentage_per_loop, :fa_repeater, :auto_dialer,
          :dot_matrix_printer, :printer_listing, :power_standby_24_alarm_5,
          :power_standby_24_alarm_15, :internal_batteries_backup_capacity_panel,
          :external_batteries_backup_time
        )
      end

      def detectors_field_devices_params
        params.require(:detectors_field_devices).permit(
          smoke_detectors: [:value, :unit_rate, :amount, :notes],
          smoke_detectors_with_built_in_isolator: [:value, :unit_rate, :amount, :notes],
          smoke_detectors_wall_mounted_with_built_in_isolator: [:value, :unit_rate, :amount, :notes],
          smoke_detectors_with_led_indicators_above_false_ceiling: [:value, :unit_rate, :amount, :notes],
          smoke_detectors_with_led_indicators_above_false_ceiling_with_isolator: [:value, :unit_rate, :amount, :notes],
          heat_detectors: [:value, :unit_rate, :amount, :notes],
          heat_detectors_with_built_in_isolator: [:value, :unit_rate, :amount, :notes],
          high_temperature_heat_detectors: [:value, :unit_rate, :amount, :notes],
          heat_rate_of_rise: [:value, :unit_rate, :amount, :notes],
          multi_detectors: [:value, :unit_rate, :amount, :notes],
          multi_detectors_with_built_in_isolator: [:value, :unit_rate, :amount, :notes],
          high_sensitive_detectors_for_harsh_conditions: [:value, :unit_rate, :amount, :notes],
          sensitivity_range: [:value, :unit_rate, :amount, :notes],
          beam_detector_transmitter: [:value, :unit_rate, :amount, :notes],
          beam_detector_receiver: [:value, :unit_rate, :amount, :notes],
          duct_smoke_detectors: [:value, :unit_rate, :amount, :notes],
          flow_switches_interface_module: [:value, :unit_rate, :amount, :notes],
          tamper_switches_interface_module: [:value, :unit_rate, :amount, :notes],
          gas_detectors: [:value, :unit_rate, :amount, :notes],
          flame_detectors: [:value, :unit_rate, :amount, :notes]
        )
      end
      
      def supplier_data_params
        params.require(:supplier_data).permit(
          :supplier_name,
          :supplier_category,
          :total_years_in_saudi_market,
          :similar_projects
        )
      end
      

    end
  end
  