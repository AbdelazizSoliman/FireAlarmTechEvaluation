module Api
  class SubsystemsController < ApplicationController
    skip_before_action :verify_authenticity_token

    COMPARISON_FIELDS = {
      fire_alarm_control_panels: {
        sheet_name: "Fire Alarm Control Panel",
        fields: {
          total_no_of_panels: { sheet_row: 3, sheet_column: 1 },
          total_number_of_loop_cards: { sheet_row: 4, sheet_column: 1 },
          total_number_of_circuits_per_card_loop: { sheet_row: 5, sheet_column: 1 },
          total_no_of_loops: { sheet_row: 6, sheet_column: 1 },
          total_no_of_spare_loops: { sheet_row: 7, sheet_column: 1 },
          total_no_of_detectors_per_loop: { sheet_row: 8, sheet_column: 1 },
          spare_no_of_loops_per_panel: { sheet_row: 9, sheet_column: 1 },
          spare_percentage_per_loop: { sheet_row: 11, sheet_column: 1 },
          fa_repeater: { sheet_row: 12, sheet_column: 1 },
          auto_dialer: { sheet_row: 13, sheet_column: 1 },
          dot_matrix_printer: { sheet_row: 14, sheet_column: 1 },
          internal_batteries_backup_capacity_panel: { sheet_row: 18, sheet_column: 1 },
          external_batteries_backup_time: { sheet_row: 19, sheet_column: 1 }
        }
      },
      detectors_field_devices: {
        sheet_name: "Detectors Field Devices",
        fields: {
          smoke_detectors_amount: { sheet_row: 1, sheet_column: 3 },
          smoke_detectors_with_built_in_isolator_amount: { sheet_row: 2, sheet_column: 3 },
          smoke_detectors_wall_mounted_with_built_in_isolator_amount: { sheet_row: 3, sheet_column: 3 },
          smoke_detectors_with_led_indicators_amount: { sheet_row: 4, sheet_column: 3 },
          smoke_detectors_with_led_and_built_in_isolator_amount: { sheet_row: 5, sheet_column: 3 },
          heat_detectors_amount: { sheet_row: 6, sheet_column: 3 },
          heat_detectors_with_built_in_isolator_amount: { sheet_row: 7, sheet_column: 3 },
          high_temperature_heat_detectors_amount: { sheet_row: 8, sheet_column: 3 },
          heat_rate_of_rise_amount: { sheet_row: 9, sheet_column: 3 },
          multi_detectors_amount: { sheet_row: 10, sheet_column: 3 },
          multi_detectors_with_built_in_isolator_amount: { sheet_row: 11, sheet_column: 3 },
          high_sensitive_detectors_for_harsh_environments_amount: { sheet_row: 12, sheet_column: 3 },
          sensitivity_range_amount: { sheet_row: 13, sheet_column: 3 },
          beam_detector_transmitter_amount: { sheet_row: 14, sheet_column: 3 },
          beam_detector_receiver_amount: { sheet_row: 15, sheet_column: 3 },
          duct_smoke_detectors_amount: { sheet_row: 16, sheet_column: 3 },
          flow_switches_interface_module_amount: { sheet_row: 17, sheet_column: 3 },
          tamper_switches_interface_module_amount: { sheet_row: 18, sheet_column: 3 },
          gas_detectors_amount: { sheet_row: 19, sheet_column: 3 },
          flame_detectors_amount: { sheet_row: 20, sheet_column: 3 }
        }
      },
      door_holders: {
        sheet_name: "Door Holders",
        fields: {
          total_no_of_devices_amount: { sheet_row: 1, sheet_column: 3 },
          total_no_of_relays_amount: { sheet_row: 2, sheet_column: 3 }
        }
      },
      # ADDING NOTIFICATION DEVICES EVALUATION
      notification_devices: {
        sheet_name: "Notification Devices",  # Make sure your standards.xlsx has this sheet name
        fields: {
          # Adjust row/column to match your actual standards.xlsx
          notification_addressing: { sheet_row: 1, sheet_column: 1 },
          fire_alarm_strobe: { sheet_row: 2, sheet_column: 1 },
          fire_alarm_strobe_wp: { sheet_row: 3, sheet_column: 1 },
          fire_alarm_horn: { sheet_row: 4, sheet_column: 1 },
          fire_alarm_horn_wp: { sheet_row: 5, sheet_column: 1 },
          fire_alarm_horn_with_strobe: { sheet_row: 6, sheet_column: 1 },
          fire_alarm_horn_with_strobe_wp: { sheet_row: 7, sheet_column: 1 }
        }
      },
      isolations: {
        sheet_name: "Isolation Data", 
        fields: {
         
        built_in_fault_isolator_for_each_detector: { sheet_row: 2, sheet_column: 1 },
        built_in_fault_isolator_for_each_mcp_bg: { sheet_row: 3, sheet_column: 1 },
        built_in_fault_isolator_for_each_sounder_horn: { sheet_row: 4, sheet_column: 1 },
        built_in_fault_isolator_for_monitor_control_modules: { sheet_row: 5, sheet_column: 1 },
        grouping_for_each_12_15: { sheet_row: 6, sheet_column: 1 }
         
        }
      }
  }
  
    def submit_all
      subsystem = Subsystem.find(params[:id])
    
      # Gather parameters for various subsystem data
      supplier_data_params        = supplier_data_params()
      fire_alarm_data             = fire_alarm_control_panel_params()
      detectors_data              = detectors_field_devices_params()
      manual_pull_station_data    = manual_pull_station_params()
      door_holders_data           = door_holders_params()
      product_data_params         = product_data_params()
      graphic_systems_params      = graphic_systems_params()
      notification_devices_data   = notification_devices_params()
      isolation_data              = isolation_params()
    
      # Build and assign data
      supplier_data_record         = subsystem.supplier_data.first_or_initialize
      supplier_data_record.assign_attributes(supplier_data_params)
    
      fire_alarm_control_panel     = subsystem.fire_alarm_control_panels.first_or_initialize
      fire_alarm_control_panel.assign_attributes(fire_alarm_data)
    
      detectors_field_device       = subsystem.detectors_field_devices.first_or_initialize
      detectors_data.each do |key, attributes|
        detectors_field_device.assign_attributes(
          "#{key}_value": attributes[:value],
          "#{key}_unit_rate": attributes[:unit_rate],
          "#{key}_amount": attributes[:amount],
          "#{key}_notes": attributes[:notes]
        )
      end
    
      manual_pull_station          = subsystem.manual_pull_stations.first_or_initialize
      manual_pull_station.assign_attributes(manual_pull_station_data)
    
      door_holders                 = subsystem.door_holders.first_or_initialize
      door_holders.assign_attributes(door_holders_data)
    
      product_data_record          = subsystem.product_data.first_or_initialize
      product_data_record.assign_attributes(product_data_params)
    
      graphic_systems_record       = subsystem.graphic_systems.first_or_initialize
      graphic_systems_record.assign_attributes(graphic_systems_params)
    
      notification_devices_record  = subsystem.notification_devices.first_or_initialize
      notification_devices_record.assign_attributes(notification_devices_data)
    
      isolation_record             = subsystem.isolations.first_or_initialize
      isolation_record.assign_attributes(isolation_data)
    
      # Perform evaluation
      evaluation_results = perform_evaluation(
        subsystem: subsystem,
        fire_alarm_control_panel: fire_alarm_control_panel,
        detectors_field_device: detectors_field_device,
        door_holders: door_holders,
        notification_devices: notification_devices_record,
        isolation_record: isolation_record
      )
    
      # Save all records and generate the report
      ActiveRecord::Base.transaction do
        [
          supplier_data_record,
          fire_alarm_control_panel,
          detectors_field_device,
          manual_pull_station,
          door_holders,
          product_data_record,
          graphic_systems_record,
          notification_devices_record,
          isolation_record
        ].each do |record|
          raise ActiveRecord::RecordInvalid.new(record) unless record.save
        end
      end
    
      report_path = generate_evaluation_report(subsystem, evaluation_results)
      relative_path = Pathname.new(report_path).relative_path_from(Rails.root.join('public')).to_s
      relative_url_path = "/" + relative_path
    
      # Create notification for evaluation
      Notification.create!(
        title: "Evaluation Submitted",
        body: "Evaluation for subsystem ##{subsystem.id} has been submitted.",
        notifiable: subsystem,
        notification_type: "evaluation",
        additional_data: {
          evaluation_report_path: relative_url_path
        }.to_json
      )
    
      render json: { message: "Data submitted successfully." }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    end
    

    private

    def perform_evaluation(subsystem:, fire_alarm_control_panel:, detectors_field_device:, door_holders:, notification_devices:, isolation_record:)
      fire_alarm_results       = evaluate_data(fire_alarm_control_panel, :fire_alarm_control_panels)
      detector_results         = evaluate_data(detectors_field_device, :detectors_field_devices)
      door_holder_results      = evaluate_data(door_holders, :door_holders)
      notification_dev_results = evaluate_data(notification_devices, :notification_devices)
      isolation_results        = evaluate_data(isolation_record, :isolations)
    
      results_hash = {
        fire_alarm_control_panels: fire_alarm_results,
        detectors_field_devices: detector_results,
        door_holders: door_holder_results,
        notification_devices: notification_dev_results,
        isolations: isolation_results
      }
    
      all_items = fire_alarm_results + detector_results + door_holder_results + notification_dev_results + isolation_results
    
      total_items = all_items.size
      total_accepted = all_items.sum { |item| item[:is_accepted] } # 1 for accepted, 0 for rejected
    
      acceptance_percentage = total_items.zero? ? 0 : (total_accepted.to_f / total_items) * 100
      overall_status = acceptance_percentage >= 60 ? "Accepted" : "Rejected"
    
      results_hash[:overall_status] = overall_status
      results_hash[:acceptance_percentage] = acceptance_percentage
    
      results_hash
    end
    

    def evaluate_data(record, table_name)
      table_config = COMPARISON_FIELDS[table_name]
      return [] unless table_config

      sheet_name = table_config[:sheet_name]
      fields = table_config[:fields]
      return [] unless sheet_name && fields

      standard_file_path = Rails.root.join('lib', 'standards.xlsx')
      standard_workbook = RubyXL::Parser.parse(standard_file_path)
      standard_sheet = standard_workbook.worksheets.find { |ws| ws.sheet_name == sheet_name }
      return [] unless standard_sheet

      results = []

      fields.each do |field, location|
        submitted_value = record.send(field) rescue nil
        cell = standard_sheet[location[:sheet_row]][location[:sheet_column]] rescue nil
        standard_value = cell&.value

        # Compare to see if accepted
        is_accepted_boolean = submitted_value.present? &&
                              standard_value.present? &&
                              submitted_value.to_i >= standard_value.to_i

        # Convert boolean => 0 or 1
        is_accepted_value = is_accepted_boolean ? 1 : 0

        results << {
          field: field.to_s.humanize,
          submitted_value: submitted_value || "N/A",
          standard_value: standard_value || "N/A",
          is_accepted: is_accepted_value
        }
      end

      results
    end

    def generate_evaluation_report(subsystem, comparison_results)
      file_name = "evaluation_report_subsystem_#{subsystem.id}_#{Time.now.to_i}.pdf"
      file_path = Rails.root.join('public', 'reports', file_name)

      Prawn::Document.generate(file_path) do |pdf|
        pdf.text "Evaluation Report", size: 30, style: :bold, align: :center
        pdf.move_down 20

        comparison_results.each do |table_name, results|
          # skip non-array keys (like :overall_status, :acceptance_percentage)
          next unless results.is_a?(Array)

          pdf.text "#{table_name.to_s.humanize} Results", size: 20, style: :bold
          pdf.move_down 10

          table_data = [["Attribute", "Submitted Value", "Standard Value", "Status"]]
          results.each do |result|
            status_text = (result[:is_accepted] == 1) ? "1" : "0"
            table_data << [
              result[:field],
              result[:submitted_value],
              result[:standard_value],
              status_text
            ]
          end

          pdf.table(table_data, header: true, position: :center, width: pdf.bounds.width) do
            row(0).font_style = :bold
            row(0).background_color = "cccccc"
            self.row_colors = ["f0f0f0", "ffffff"]
          end
          pdf.move_down 20
        end

        # Show overall acceptance
        overall  = comparison_results[:overall_status]
        percent  = comparison_results[:acceptance_percentage].round(2)

        pdf.text "Overall Acceptance: #{percent}%"
        pdf.text "Overall Status: #{overall}"
      end

      file_path.to_s
    end

    #--------------------------------------------------
    # STRONG PARAMS
    #--------------------------------------------------
    def supplier_data_params
      params.require(:supplier_data).permit(
        :supplier_name, :supplier_category,
        :total_years_in_saudi_market, :similar_projects
      )
    end

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

    def notification_devices_params
      params.require(:notification_devices).permit(
        :notification_addressing,
        :fire_alarm_strobe,
        :fire_alarm_strobe_wp,
        :fire_alarm_horn,
        :fire_alarm_horn_wp,
        :fire_alarm_horn_with_strobe,
        :fire_alarm_horn_with_strobe_wp
      )
    end

    def isolation_params
      params.require(:isolations).permit(
        :built_in_fault_isolator_for_each_detector,
        :built_in_fault_isolator_for_each_mcp_bg,
        :built_in_fault_isolator_for_each_sounder_horn,
        :built_in_fault_isolator_for_monitor_control_modules,
        :grouping_for_each_12_15
      )
    end
    
  end
end
