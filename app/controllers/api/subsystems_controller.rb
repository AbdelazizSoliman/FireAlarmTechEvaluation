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
          external_batteries_backup_time: { sheet_row: 19, sheet_column: 1 },
        },
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
          flame_detectors_amount: { sheet_row: 20, sheet_column: 3 },
        },
      },
      door_holders: {
        sheet_name: "Door Holders",
        fields: {
          total_no_of_devices_amount: { sheet_row: 1, sheet_column: 3 },
          total_no_of_relays_amount: { sheet_row: 2, sheet_column: 3 },
        },
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
          fire_alarm_horn_with_strobe_wp: { sheet_row: 7, sheet_column: 1 },
        },
      },
      isolations: {
        sheet_name: "Isolation Data",
        fields: {

          built_in_fault_isolator_for_each_detector: { sheet_row: 2, sheet_column: 1 },
          built_in_fault_isolator_for_each_mcp_bg: { sheet_row: 3, sheet_column: 1 },
          built_in_fault_isolator_for_each_sounder_horn: { sheet_row: 4, sheet_column: 1 },
          built_in_fault_isolator_for_monitor_control_modules: { sheet_row: 5, sheet_column: 1 },
          grouping_for_each_12_15: { sheet_row: 6, sheet_column: 1 },

        },
      },
    }

    def submit_all
      subsystem = Subsystem.find(params[:id])

      ActiveRecord::Base.transaction do
        # Keep your existing code
        if params[:supplier_data].present?
          supplier_data_record = subsystem.supplier_data.first_or_initialize
          supplier_data_record.assign_attributes(supplier_data_params)
          supplier_data_record.save!
        end

        if params[:fire_alarm_control_panel].present?
          fire_alarm_control_panel = subsystem.fire_alarm_control_panels.first_or_initialize
          fire_alarm_control_panel.assign_attributes(fire_alarm_control_panel_params)
          fire_alarm_control_panel.save!
        end

        if params[:detectors_field_devices].present?
          detectors_field_device = subsystem.detectors_field_devices.first_or_initialize
          params[:detectors_field_devices].each do |key, attributes|
            detectors_field_device.assign_attributes(
              "#{key}_value": attributes[:value],
              "#{key}_unit_rate": attributes[:unit_rate],
              "#{key}_amount": attributes[:amount],
              "#{key}_notes": attributes[:notes],
            )
          end
          detectors_field_device.save!
        end

        if params[:notification_devices].present?
          notification_devices_record = subsystem.notification_devices.first_or_initialize
          notification_devices_record.assign_attributes(notification_devices_params)
          notification_devices_record.save!
        end

        # ✅ Generate Evaluation Report and Save Notification
        evaluation_results = perform_evaluation(
          subsystem: subsystem,
          fire_alarm_control_panel: subsystem.fire_alarm_control_panels.first,
          detectors_field_device: subsystem.detectors_field_devices.first,
          door_holders: subsystem.door_holders.first,
          notification_devices: subsystem.notification_devices.first,
          isolation_record: subsystem.isolations.first
        )

        # ✅ Generate Evaluation Report
        report_path = generate_evaluation_report(subsystem, evaluation_results)
        relative_path = Pathname.new(report_path).relative_path_from(Rails.root.join("public")).to_s
        relative_url_path = "/" + relative_path

        # ✅ Create Notification After Submission
        Notification.create!(
          title: "Evaluation Submitted",
          body: "Evaluation for subsystem ##{subsystem.id} has been submitted.",
          notifiable: subsystem,
          notification_type: "evaluation",
          additional_data: { evaluation_report_path: relative_url_path }.to_json
        )
      end

      render json: { message: "Data submitted successfully." }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error "🚨 Error submitting data: #{e.message}"
      render json: { error: "An error occurred: #{e.message}" }, status: :internal_server_error
    end


    private

     def perform_evaluation(subsystem:, fire_alarm_control_panel:, detectors_field_device:, door_holders:, notification_devices:, isolation_record:)
      fire_alarm_results = evaluate_data(fire_alarm_control_panel, :fire_alarm_control_panels)
      detector_results = evaluate_data(detectors_field_device, :detectors_field_devices)
      door_holder_results = evaluate_data(door_holders, :door_holders)
      notification_dev_results = evaluate_data(notification_devices, :notification_devices)
      isolation_results = evaluate_data(isolation_record, :isolations)

      results_hash = {
        fire_alarm_control_panels: fire_alarm_results,
        detectors_field_devices: detector_results,
        door_holders: door_holder_results,
        notification_devices: notification_dev_results,
        isolations: isolation_results,
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

      standard_file_path = Rails.root.join("lib", "standards.xlsx")
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
          is_accepted: is_accepted_value,
        }
      end

      results
    end

    def generate_evaluation_report(subsystem, comparison_results)
      file_name = "evaluation_report_subsystem_#{subsystem.id}_#{Time.now.to_i}.pdf"
      file_path = Rails.root.join("public", "reports", file_name)

      Prawn::Document.generate(file_path) do |pdf|
        pdf.text "Evaluation Report", size: 30, style: :bold, align: :center
        pdf.move_down 20

        comparison_results.each do |table_name, results|
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
              status_text,
            ]
          end

          pdf.table(table_data, header: true, position: :center, width: pdf.bounds.width) do
            row(0).font_style = :bold
            row(0).background_color = "cccccc"
            self.row_colors = ["f0f0f0", "ffffff"]
          end
          pdf.move_down 20
        end

        overall = comparison_results[:overall_status]
        percent = comparison_results[:acceptance_percentage].round(2)

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
        flame_detectors: [:value, :unit_rate, :amount, :notes],
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

    def connection_betweens_params
      params.require(:connection_betweens).permit(
        :connection_type,
        :network_module,
        :cables_for_connection
      )
    end

    def interface_with_other_params
      params.require(:interface_with_other_systems).permit(
        :integration_type,
        :total_no_of_control_modules,
        :total_no_of_monitor_modules,
        :total_no_of_dual_monitor_modules,
        :total_no_of_zone_module
      )
    end

    def evacuation_systems_params
      params.require(:evacuation_systems).permit(
        :included_in_fire_alarm_system,
        :evacuation_system_part_of_fa_panel,
        :amplifier_power_output,
        :total_no_of_amplifiers,
        :total_no_of_evacuations_speakers_circuits,
        :total_no_of_wattage_per_panel,
        :fire_rated_speakers_watt,
        :speakers_tapping_watt,
        :total_no_of_speakers
      )
    end

    def prerecorded_message_audio_modules_params
      params.require(:prerecorded_message_audio_modules).permit(
        :message_type,
        :total_time_for_messages,
        :total_no_of_voice_messages,
        :message_storage_location,
        :master_microphone
      )
    end

    def telephone_system_params
      params.require(:telephone_systems).permit(
        :number_of_firefighter_telephone_circuits_per_panel,
        :total_no_of_firefighter_telephone_cabinet,
        :total_no_of_firefighter_phones,
        :total_no_of_firefighter_jacks
      )
    end

    def spare_parts_params
      params.require(:spare_parts).permit(
        :total_no_of_device1,
        :total_no_of_device2,
        :total_no_of_device3,
        :total_no_of_device4
      )
    end

    def scope_of_work_params
      params.require(:scope_of_works).permit(
        :supply,
        :install,
        :supervision_test_commissioning,
        :cables_supply,
        :cables_size_2cx1_5_mm,
        :cables_size_2cx2_5_mm,
        :pulling_cables,
        :cables_terminations,
        :supervision_test_commissioning,
        :design_review_verification,
        :heat_map_study,
        :voltage_drop_study_for_initiating_devices_loop,
        :voltage_drop_notification_circuits,
        :battery_calculation,
        :cause_effect_matrix,
        :high_level_riser_diagram,
        :shop_drawings,
        :shop_drawings_verification,
        :training_days
      )
    end

    def material_delivery_params
      params.require(:material_and_deliveries).permit(
        :material_availability,
        :delivery_time_period,
        :delivery_type,
        :delivery_to
      )
    end

    def general_commercial_params
      params.require(:general_commercial_data).permit(
        :warranty_for_materials,
        :warranty_for_configuration_programming,
        :support_and_maintenance,
        :spare_parts_availability,
        :advanced_payment_minimum_acceptable,
        :performance_bond_equivalent_warranty,
        :total_price_excluding_vat
      )
    end
  end
end
