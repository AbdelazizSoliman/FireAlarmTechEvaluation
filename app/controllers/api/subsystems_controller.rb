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
      }
    }

    def submit_all
      subsystem = Subsystem.find(params[:id])

      # Gather parameters for various subsystem data
      supplier_data_params = supplier_data_params()
      fire_alarm_data = fire_alarm_control_panel_params()
      detectors_data = detectors_field_devices_params()
      manual_pull_station_data = manual_pull_station_params()
      door_holders_data = door_holders_params()
      product_data_params = product_data_params()
      graphic_systems_params = graphic_systems_params()

      # Build and assign data to their respective models
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

      # Perform evaluation
      evaluation_results = {
        fire_alarm_control_panels: evaluate_data(fire_alarm_control_panel, :fire_alarm_control_panels),
        detectors_field_devices: evaluate_data(detectors_field_device, :detectors_field_devices),
        door_holders: evaluate_data(door_holders, :door_holders)
      }

      # Save all records and generate report
      ActiveRecord::Base.transaction do
        [supplier_data_record, fire_alarm_control_panel, detectors_field_device,
         manual_pull_station, door_holders, product_data_record, graphic_systems_record].each do |record|
          unless record.save
            raise ActiveRecord::RecordInvalid.new(record)
          end
        end
      end

      report_path = generate_evaluation_report(subsystem, evaluation_results)

      # Create notification for evaluation
      Notification.create!(
        title: "Evaluation Submitted",
        body: "Evaluation for subsystem ##{subsystem.id} has been submitted.",
        notifiable: subsystem,
        notification_type: "evaluation",
        additional_data: { evaluation_report_path: report_path }.to_json
      )

      render json: { message: "Data submitted successfully." }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    private

    def evaluate_data(record, table_name)
      # Debugging: Log the table name and comparison fields
      Rails.logger.debug "Evaluating table: #{table_name}"
      table_config = COMPARISON_FIELDS[table_name]
    
      unless table_config
        Rails.logger.error "No configuration found for table: #{table_name}"
        return []
      end
    
      sheet_name = table_config[:sheet_name]
      fields = table_config[:fields]
    
      unless sheet_name && fields
        Rails.logger.error "Missing sheet_name or fields for table: #{table_name}"
        return []
      end
    
      # Load the standard Excel file
      standard_file_path = Rails.root.join('lib', 'standards.xlsx')
      standard_workbook = RubyXL::Parser.parse(standard_file_path)
      standard_sheet = standard_workbook.worksheets.find { |sheet| sheet.sheet_name == sheet_name }
    
      unless standard_sheet
        Rails.logger.error "Worksheet #{sheet_name} not found for table: #{table_name}"
        return []
      end
    
      results = []
    
      fields.each do |field, location|
        # Fetch submitted value
        submitted_value = record.send(field) rescue nil
    
        # Check and fetch the standard value
        cell = standard_sheet[location[:sheet_row]][location[:sheet_column]] rescue nil
        standard_value = cell&.value
    
        if standard_value.nil?
          Rails.logger.error "Missing standard value for #{field} at row #{location[:sheet_row]}, column #{location[:sheet_column]} in #{sheet_name}"
        end
    
        # Compare values
        is_accepted = submitted_value.present? && standard_value.present? && submitted_value.to_i >= standard_value.to_i
    
        # Append the comparison result
        results << {
          field: field.to_s.humanize,
          submitted_value: submitted_value || "N/A",
          standard_value: standard_value || "N/A",
          is_accepted: is_accepted
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
          pdf.text "#{table_name.to_s.humanize} Results", size: 20, style: :bold
          pdf.move_down 10

          table_data = [["Attribute", "Submitted Value", "Standard Value", "Status"]]
          results.each do |result|
            status = result[:is_accepted] ? "Accepted" : "Rejected"
            table_data << [result[:field], result[:submitted_value], result[:standard_value], status]
          end

          pdf.table(table_data, header: true, position: :center, width: pdf.bounds.width) do
            row(0).font_style = :bold
            row(0).background_color = "cccccc"
            self.row_colors = ["f0f0f0", "ffffff"]
          end
          pdf.move_down 20
        end
      end

      file_path.to_s
    end

    # Permit parameters
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
