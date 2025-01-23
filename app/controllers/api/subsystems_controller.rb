module Api
    class SubsystemsController < ApplicationController
      skip_before_action :verify_authenticity_token
  
      COMPARISON_FIELDS = {
      total_no_of_panels: { sheet_row: 1, sheet_column: 2 },
      total_number_of_loop_cards: { sheet_row: 1, sheet_column: 3 },
      total_number_of_circuits_per_card_loop: { sheet_row: 1, sheet_column: 4 },
      total_no_of_loops: { sheet_row: 1, sheet_column: 5 },
      total_no_of_spare_loops: { sheet_row: 1, sheet_column: 6 },
      total_no_of_detectors_per_loop: { sheet_row: 1, sheet_column: 7 },
      spare_no_of_loops_per_panel: { sheet_row: 1, sheet_column: 8 },
      spare_percentage_per_loop: { sheet_row: 1, sheet_column: 10},
      fa_repeater: { sheet_row: 1, sheet_column: 11 },
      auto_dialer: { sheet_row: 1, sheet_column: 12 },
      dot_matrix_printer: { sheet_row: 1, sheet_column: 13 },
      internal_batteries_backup_capacity_panel: { sheet_row: 1, sheet_column: 17 },
      external_batteries_backup_time: { sheet_row: 1, sheet_column: 18 }
    }

    

      def submit_all
        subsystem = Subsystem.find(params[:id])
      
        supplier_data_params = supplier_data_params()
        fire_alarm_data = fire_alarm_control_panel_params()
        detectors_data = detectors_field_devices_params()
        manual_pull_station_data = manual_pull_station_params()
        door_holders_data = door_holders_params()
        product_data_params = product_data_params()
        graphic_systems_params = graphic_systems_params()
      
        supplier_data_record = subsystem.supplier_data.first_or_initialize
        supplier_data_record.assign_attributes(supplier_data_params)
      
        fire_alarm_control_panel = subsystem.fire_alarm_control_panels.new(fire_alarm_data)
      
        detectors_field_device = subsystem.detectors_field_devices.first_or_initialize
        detectors_data.each do |key, attributes|
          detectors_field_device.assign_attributes(
            "#{key}_value": attributes[:value],
            "#{key}_unit_rate": attributes[:unit_rate],
            "#{key}_amount": attributes[:amount],
            "#{key}_notes": attributes[:notes]
          )
        end
      
        manual_pull_station = subsystem.manual_pull_stations.first_or_initialize
        manual_pull_station.assign_attributes(manual_pull_station_data)
      
        door_holders = subsystem.door_holders.first_or_initialize
        door_holders.assign_attributes(door_holders_data)
      
        product_data_record = subsystem.product_data.first_or_initialize
        product_data_record.assign_attributes(product_data_params)
      
        graphic_systems_record = subsystem.graphic_systems.first_or_initialize
        graphic_systems_record.assign_attributes(graphic_systems_params)
      
        ActiveRecord::Base.transaction do
          [supplier_data_record, fire_alarm_control_panel, detectors_field_device, 
           manual_pull_station, door_holders, product_data_record, graphic_systems_record].each do |record|
            unless record.save
              raise ActiveRecord::RecordInvalid.new(record)
            end
          end
        end
      
        Notification.create!(
          title: "Evaluation Submitted",
          body: "Evaluation for subsystem ##{subsystem.id} has been submitted.",
          notifiable: subsystem,
          notification_type: "evaluation",
          additional_data: { subsystem_id: subsystem.id }.to_json
        )
      
        render json: { message: "Data submitted successfully." }, status: :created
      rescue ActiveRecord::RecordInvalid => e
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
          smoke_detectors_with_led_indicators: [:value, :unit_rate, :amount, :notes],
          smoke_detectors_with_led_and_built_in_isolator: [:value, :unit_rate, :amount, :notes],
          heat_detectors: [:value, :unit_rate, :amount, :notes],
          heat_detectors_with_built_in_isolator: [:value, :unit_rate, :amount, :notes],
          high_temperature_heat_detectors: [:value, :unit_rate, :amount, :notes],
          heat_rate_of_rise: [:value, :unit_rate, :amount, :notes],
          multi_detectors: [:value, :unit_rate, :amount, :notes],
          multi_detectors_with_built_in_isolator: [:value, :unit_rate, :amount, :notes],
          high_sensitive_detectors_for_harsh_environments: [:value, :unit_rate, :amount, :notes],
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
  
      def manual_pull_station_params
        params.require(:manual_pull_station).permit(
          :type, :break_glass, :break_glass_weather_proof
        )
      end
  
      def door_holders_params
        params.require(:door_holders).permit(
          :total_no_of_devices, :total_no_of_devices_unit_rate, :total_no_of_devices_amount, :total_no_of_devices_notes,
          :total_no_of_relays, :total_no_of_relays_unit_rate, :total_no_of_relays_amount, :total_no_of_relays_notes
        )
      end
  
      def supplier_data_params
        params.require(:supplier_data).permit(
          :supplier_name, :supplier_category,
          :total_years_in_saudi_market, :similar_projects
        )
      end

      def product_data_params
        params.require(:product_data).permit(
          :manufacturer, :submitted_product, :product_certifications,
          :total_years_in_saudi_market, :coo, :com_for_mfacp, :com_for_detectors
        )
      end
      
      def graphic_systems_params
        params.require(:graphic_systems).permit(
          :workstation, :workstation_control_feature, :softwares, :licenses, :screens
        )
      end
      
    end
  end
  