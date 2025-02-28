module Api
  class SubsystemsController < ApplicationController
    skip_before_action :verify_authenticity_token

    COMPARISON_FIELDS = {
      fire_alarm_control_panels: {
        sheet_name: 'Fire Alarm Control Panel',
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
        sheet_name: 'Detectors Field Devices',
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
      # NEW: Manual Pull Station fields (ensure key naming matches your association)
      manual_pull_stations: {
        sheet_name: 'Manual Pull Station',
        fields: {
          type: { sheet_row: 3, sheet_column: 1 },
          break_glass: { sheet_row: 4, sheet_column: 1 },
          break_glass_weather_proof: { sheet_row: 5, sheet_column: 1 }
        }
      },
      door_holders: {
        sheet_name: 'Door Holders',
        fields: {
          total_no_of_devices_amount: { sheet_row: 1, sheet_column: 3 },
          total_no_of_relays_amount: { sheet_row: 2, sheet_column: 3 }
        }
      },
      # ADDING NOTIFICATION DEVICES EVALUATION
      notification_devices: {
        sheet_name: 'Notification Devices', # Make sure your standards.xlsx has this sheet name
        fields: {
          notification_addressing: { sheet_row: 2, sheet_column: 1 },
          fire_alarm_strobe: { sheet_row: 3, sheet_column: 1 },
          fire_alarm_strobe_wp: { sheet_row: 4, sheet_column: 1 },
          fire_alarm_horn: { sheet_row: 5, sheet_column: 1 },
          fire_alarm_horn_wp: { sheet_row: 6, sheet_column: 1 },
          fire_alarm_horn_with_strobe: { sheet_row: 7, sheet_column: 1 },
          fire_alarm_horn_with_strobe_wp: { sheet_row: 8, sheet_column: 1 }
        }
      },
      isolations: {
        sheet_name: 'Isolation Data',
        fields: {
          built_in_fault_isolator_for_each_detector: { sheet_row: 2, sheet_column: 1 },
          built_in_fault_isolator_for_each_mcp_bg: { sheet_row: 3, sheet_column: 1 },
          built_in_fault_isolator_for_each_sounder_horn: { sheet_row: 4, sheet_column: 1 },
          built_in_fault_isolator_for_monitor_control_modules: { sheet_row: 5, sheet_column: 1 },
          grouping_for_each_12_15: { sheet_row: 6, sheet_column: 1 }
        }
      },
      # NEW: Evacuation Systems fields
      evacuation_systems: {
        sheet_name: 'Evacuation Systems',
        fields: {
          amplifier_power_output: { sheet_row: 4, sheet_column: 1 },
          total_no_of_amplifiers: { sheet_row: 5, sheet_column: 1 },
          total_no_of_evacuation_speakers_circuits: { sheet_row: 6, sheet_column: 1 },
          total_no_of_wattage_per_panel: { sheet_row: 7, sheet_column: 1 },
          fire_rated_speakers_watt: { sheet_row: 8, sheet_column: 1 },
          speakers_tapping_watt: { sheet_row: 9, sheet_column: 1 },
          total_no_of_speakers: { sheet_row: 10, sheet_column: 1 }
        }
      },
      # NEW: Telephone Systems fields
      telephone_systems: {
        sheet_name: 'Telephone System',
        fields: {
          number_of_firefighter_telephone_circuits_per_panel: { sheet_row: 2, sheet_column: 1 },
          total_no_of_firefighter_telephone_cabinet: { sheet_row: 3, sheet_column: 1 },
          total_no_of_firefighter_phones: { sheet_row: 4, sheet_column: 1 },
          total_no_of_firefighter_jacks: { sheet_row: 5, sheet_column: 1 }
        }
      },
      # NEW: General & Commercial Data fields
      general_commercial_data: {
        sheet_name: 'General & Commercial Data',
        fields: {
          warranty_for_materials: { sheet_row: 2, sheet_column: 1 },
          warranty_for_configuration_programming: { sheet_row: 3, sheet_column: 1 },
          support_and_maintenance: { sheet_row: 4, sheet_column: 1 },
          spare_parts_availability: { sheet_row: 5, sheet_column: 1 },
          advanced_payment_minimum: { sheet_row: 6, sheet_column: 1 },
          performance_bond: { sheet_row: 7, sheet_column: 1 },
          total_price_excluding_vat: { sheet_row: 8, sheet_column: 1 }
        }
      }
    }

    def submit_all
      subsystem = Subsystem.find(params[:id])
      supplier = current_supplier || ::Supplier.find_by(id: params[:supplier_id]) # Ensure supplier exists

      if supplier.nil?
        Rails.logger.error "🚨 Supplier not found! Params: #{params.inspect}"
        render json: { error: 'Supplier not found. Please log in again.' }, status: :unauthorized
        return
      end

      ActiveRecord::Base.transaction do
        if params[:supplier_data].present?
          supplier_data_record = subsystem.supplier_data.find_or_initialize_by(supplier_id: supplier.id)
          supplier_data_record.assign_attributes(supplier_data_params)
          supplier_data_record.supplier_id = supplier.id
          supplier_data_record.save!
        end

        if params[:fire_alarm_control_panel].present?
          fire_alarm_control_panel = subsystem.fire_alarm_control_panels.find_or_initialize_by(supplier_id: supplier.id)
          fire_alarm_control_panel.assign_attributes(fire_alarm_control_panel_params)
          fire_alarm_control_panel.supplier_id = supplier.id
          fire_alarm_control_panel.save!
        end

        if params[:detectors_field_devices].present?
          detectors_field_device = subsystem.detectors_field_devices.find_or_initialize_by(supplier_id: supplier.id)
          params[:detectors_field_devices].each do |key, attributes|
            detectors_field_device.assign_attributes(
              "#{key}_value": attributes[:value],
              "#{key}_unit_rate": attributes[:unit_rate],
              "#{key}_amount": attributes[:amount],
              "#{key}_notes": attributes[:notes]
            )
          end
          detectors_field_device.supplier_id = supplier.id
          detectors_field_device.save!
        end

        if params[:notification_devices].present?
          notification_devices_record = subsystem.notification_devices.find_or_initialize_by(supplier_id: supplier.id)
          notification_devices_record.assign_attributes(notification_devices_params)
          notification_devices_record.supplier_id = supplier.id
          notification_devices_record.save!
        end

        # Manual Pull Station
        if params[:manual_pull_station].present?
          manual_pull_station = subsystem.manual_pull_stations.find_or_initialize_by(supplier_id: supplier.id)
          manual_pull_station.assign_attributes(manual_pull_station_params)
          manual_pull_station.supplier_id = supplier.id
          manual_pull_station.save!
        end

        # Door Holders
        if params[:door_holders].present?
          door_holder = subsystem.door_holders.find_or_initialize_by(supplier_id: supplier.id)

          # Assign attributes correctly based on the structure of `params[:door_holders]`
          door_holder.assign_attributes(
            total_no_of_devices: params[:door_holders][:total_no_of_devices],
            total_no_of_devices_unit_rate: params[:door_holders][:total_no_of_devices_unit_rate],
            total_no_of_devices_amount: params[:door_holders][:total_no_of_devices_amount],
            total_no_of_devices_notes: params[:door_holders][:total_no_of_devices_notes],
            total_no_of_relays: params[:door_holders][:total_no_of_relays],
            total_no_of_relays_unit_rate: params[:door_holders][:total_no_of_relays_unit_rate],
            total_no_of_relays_amount: params[:door_holders][:total_no_of_relays_amount],
            total_no_of_relays_notes: params[:door_holders][:total_no_of_relays_notes]
          )
          door_holder.supplier_id = supplier.id
          if door_holder.save
            Rails.logger.info "Door Holders saved successfully: #{door_holder.inspect}"
          else
            Rails.logger.error "Failed to save Door Holders: #{door_holder.errors.full_messages}"
          end
        end

        # Product Data
        if params[:product_data].present?
          product_data_record = subsystem.product_data.find_or_initialize_by(supplier_id: supplier.id)
          product_data_record.assign_attributes(product_data_params)
          product_data_record.supplier_id = supplier.id
          product_data_record.save!
        end

        # Graphic Systems
        if params[:graphic_systems].present?
          graphic_systems_record = subsystem.graphic_systems.find_or_initialize_by(supplier_id: supplier.id)
          graphic_systems_record.assign_attributes(graphic_systems_params)
          graphic_systems_record.supplier_id = supplier.id
          graphic_systems_record.save!
        end

        # Isolations
        if params[:isolations].present?
          isolation_record = subsystem.isolations.find_or_initialize_by(supplier_id: supplier.id)
          isolation_record.assign_attributes(isolation_params)
          isolation_record.supplier_id = supplier.id
          isolation_record.save!
        end

        # Connection Betweens
        if params[:connection_betweens].present?
          connection_betweens_record = subsystem.connection_betweens.find_or_initialize_by(supplier_id: supplier.id)
          connection_betweens_record.assign_attributes(connection_betweens_params)
          connection_betweens_record.supplier_id = supplier.id
          connection_betweens_record.save!
        end

        # Interface With Other Systems
        if params[:interface_with_other_systems].present?
          interface_with_other_record = subsystem.interface_with_other_systems.find_or_initialize_by(supplier_id: supplier.id)
          interface_with_other_record.assign_attributes(interface_with_other_params)
          interface_with_other_record.supplier_id = supplier.id
          interface_with_other_record.save!
        end

        # Evacuation Systems
        if params[:evacuation_systems].present?
          evacuation_systems_record = subsystem.evacuation_systems.find_or_initialize_by(supplier_id: supplier.id)
          evacuation_systems_record.assign_attributes(evacuation_systems_params)
          evacuation_systems_record.supplier_id = supplier.id
          evacuation_systems_record.save!
        end

        # Prerecorded Message Audio Modules
        if params[:prerecorded_message_audio_modules].present?
          prerecorded_message_audio_modules_record = subsystem.prerecorded_message_audio_modules.find_or_initialize_by(supplier_id: supplier.id)
          prerecorded_message_audio_modules_record.assign_attributes(prerecorded_message_audio_modules_params)
          prerecorded_message_audio_modules_record.supplier_id = supplier.id
          prerecorded_message_audio_modules_record.save!
        end

        # Telephone System
        if params[:telephone_systems].present?
          telephone_system_record = subsystem.telephone_systems.find_or_initialize_by(supplier_id: supplier.id)
          telephone_system_record.assign_attributes(telephone_system_params)
          telephone_system_record.supplier_id = supplier.id
          telephone_system_record.save!
        end

        # Spare Parts
        if params[:spare_parts].present?
          spare_parts_record = subsystem.spare_parts.find_or_initialize_by(supplier_id: supplier.id)
          spare_parts_record.assign_attributes(spare_parts_params)
          spare_parts_record.supplier_id = supplier.id
          spare_parts_record.save!
        end

        # Scope of Work
        if params[:scope_of_works].present?
          scope_of_work_record = subsystem.scope_of_works.find_or_initialize_by(supplier_id: supplier.id)
          scope_of_work_record.assign_attributes(scope_of_work_params)
          scope_of_work_record.supplier_id = supplier.id
          scope_of_work_record.save!
        end

        # Material Delivery
        if params[:material_and_deliveries].present?
          material_delivery_record = subsystem.material_and_deliveries.find_or_initialize_by(supplier_id: supplier.id)
          material_delivery_record.assign_attributes(material_delivery_params)
          material_delivery_record.supplier_id = supplier.id
          material_delivery_record.save!
        end

        # General Commercial Data
        if params[:general_commercial_data].present?
          general_commercial_record = subsystem.general_commercial_data.find_or_initialize_by(supplier_id: supplier.id)
          general_commercial_record.assign_attributes(general_commercial_params)
          general_commercial_record.supplier_id = supplier.id
          general_commercial_record.save!
        end
        # ✅ Generate Evaluation Report and Save Notification
        evaluation_results = perform_evaluation(
          subsystem: subsystem,
          fire_alarm_control_panel: subsystem.fire_alarm_control_panels.find_by(supplier_id: supplier.id),
          detectors_field_device: subsystem.detectors_field_devices.find_by(supplier_id: supplier.id),
          door_holders: subsystem.door_holders.find_by(supplier_id: supplier.id),
          notification_devices: subsystem.notification_devices.find_by(supplier_id: supplier.id),
          isolation_record: subsystem.isolations.find_by(supplier_id: supplier.id),
          # NEW: Additional fields
          manual_pull_station: subsystem.manual_pull_stations.find_by(supplier_id: supplier.id),
          evacuation_systems: subsystem.evacuation_systems.find_by(supplier_id: supplier.id),
          telephone_systems: subsystem.telephone_systems.find_by(supplier_id: supplier.id),
          general_commercial_data: subsystem.general_commercial_data.find_by(supplier_id: supplier.id)
        )

        # 🔹 Generate a report with a unique file name for the supplier and subsystem
        # report_path = generate_evaluation_report(subsystem, supplier, evaluation_results)
        # relative_path = Pathname.new(report_path).relative_path_from(Rails.root.join('public')).to_s
        # relative_url_path = '/' + relative_path

        # UPDATED: Update the notification message with supplier and subsystem names
        Notification.create!(
          title: 'Evaluation Submitted',
          body: "#{supplier.supplier_name} has submitted evaluation for subsystem ##{subsystem.name}.",
          notifiable: subsystem,
          notification_type: 'evaluation',
          additional_data: { supplier_id: supplier.id }.to_json
        )
      end

      render json: { message: 'Data submitted successfully.' }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error "🚨 Error submitting data: #{e.message}"
      render json: { error: "An error occurred: #{e.message}" }, status: :internal_server_error
    end

    def submitted_data
      subsystem = Subsystem.find(params[:id])
      supplier = current_supplier

      if supplier.nil?
        render json: { error: 'Supplier not found. Please log in again.' }, status: :unauthorized
        return
      end

      render json: {
        submission: {
          id: subsystem.id,
          supplier_data: subsystem.supplier_data.where(supplier_id: supplier.id),
          product_data: subsystem.product_data.where(supplier_id: supplier.id),
          fire_alarm_control_panels: subsystem.fire_alarm_control_panels.where(supplier_id: supplier.id),
          graphic_systems: subsystem.graphic_systems.where(supplier_id: supplier.id),
          detectors_field_devices: subsystem.detectors_field_devices.where(supplier_id: supplier.id),
          manual_pull_stations: subsystem.manual_pull_stations.where(supplier_id: supplier.id),
          door_holders: subsystem.door_holders.where(supplier_id: supplier.id),
          notification_devices: subsystem.notification_devices.where(supplier_id: supplier.id),
          isolations: subsystem.isolations.where(supplier_id: supplier.id),
          connection_betweens: subsystem.connection_betweens.where(supplier_id: supplier.id),
          interface_with_other_systems: subsystem.interface_with_other_systems.where(supplier_id: supplier.id),
          evacuation_systems: subsystem.evacuation_systems.where(supplier_id: supplier.id),
          prerecorded_message_audio_modules: subsystem.prerecorded_message_audio_modules.where(supplier_id: supplier.id),
          telephone_systems: subsystem.telephone_systems.where(supplier_id: supplier.id),
          spare_parts: subsystem.spare_parts.where(supplier_id: supplier.id),
          scope_of_works: subsystem.scope_of_works.where(supplier_id: supplier.id),
          material_and_deliveries: subsystem.material_and_deliveries.where(supplier_id: supplier.id),
          general_commercial_data: subsystem.general_commercial_data.where(supplier_id: supplier.id)
        }
      }, status: :ok
    end

    def update_submission
      subsystem = Subsystem.find(params[:id])

      if subsystem.update(submission_params)
        render json: { message: 'Submission updated successfully.', submission: subsystem }, status: :ok
      else
        render json: { error: subsystem.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def submission_params
      params.require(:submission).permit(
        :name, :system_id,
        general_commercial_data_attributes: %i[
          id warranty_for_materials warranty_for_configuration_programming
          support_and_maintenance spare_parts_availability advanced_payment_minimum
          performance_bond total_price_excluding_vat subsystem_id supplier_id
        ],
        supplier_data_attributes: %i[
          id supplier_name supplier_category total_years_in_saudi_market similar_projects subsystem_id
        ],
        product_data_attributes: %i[
          id manufacturer submitted_product product_certifications total_years_in_saudi_market coo
          com_for_mfacp com_for_detectors subsystem_id
        ],
        fire_alarm_control_panels_attributes: %i[
          id standards
          total_no_of_panels total_no_of_panels_unit_rate total_no_of_panels_amount total_no_of_panels_notes
          total_number_of_loop_cards total_number_of_loop_cards_unit_rate total_number_of_loop_cards_amount total_number_of_loop_cards_notes
          total_number_of_circuits_per_card_loop total_number_of_circuits_per_card_loop_unit_rate total_number_of_circuits_per_card_loop_amount total_number_of_circuits_per_card_loop_notes
          total_no_of_loops total_no_of_loops_unit_rate total_no_of_loops_amount total_no_of_loops_notes
          total_no_of_spare_loops total_no_of_spare_loops_unit_rate total_no_of_spare_loops_amount total_no_of_spare_loops_notes
          total_no_of_detectors_per_loop total_no_of_detectors_per_loop_unit_rate total_no_of_detectors_per_loop_amount total_no_of_detectors_per_loop_notes
          spare_no_of_loops_per_panel spare_no_of_loops_per_panel_unit_rate spare_no_of_loops_per_panel_amount spare_no_of_loops_per_panel_notes
          initiating_devices_polarity_insensitivity
          spare_percentage_per_loop spare_percentage_per_loop_unit_rate spare_percentage_per_loop_amount spare_percentage_per_loop_notes
          fa_repeater fa_repeater_unit_rate fa_repeater_amount fa_repeater_notes
          auto_dialer auto_dialer_unit_rate auto_dialer_amount auto_dialer_notes
          dot_matrix_printer dot_matrix_printer_unit_rate dot_matrix_printer_amount dot_matrix_printer_notes
          printer_listing
          power_standby_24_alarm_5 power_standby_24_alarm_15
          internal_batteries_backup_capacity_panel internal_batteries_backup_capacity_panel_unit_rate internal_batteries_backup_capacity_panel_amount internal_batteries_backup_capacity_panel_notes
          external_batteries_backup_time external_batteries_backup_time_unit_rate external_batteries_backup_time_amount external_batteries_backup_time_notes
          subsystem_id supplier_id
        ],

        detectors_field_devices_attributes: %i[
          id smoke_detectors smoke_detectors_with_built_in_isolator smoke_detectors_wall_mounted_with_built_in_isolator
          smoke_detectors_with_led_indicators smoke_detectors_with_led_and_built_in_isolator heat_detector
          heat_detectors_with_built_in_isolator high_temperature_heat_detector heat_rate_of_rise multi_detectors
          multi_detectors_with_built_in_isolator high_sensitive_detectors_for_harsh_environments sensitivity_range
          beam_detector_transmitter beam_detector_receiver duct_smoke_detectors flow_switches_interface_module
          tamper_switches_interface_module gas_detectors flame_detectors
          smoke_detectors_value smoke_detectors_unit_rate smoke_detectors_amount smoke_detectors_notes
          smoke_detectors_with_built_in_isolator_value smoke_detectors_with_built_in_isolator_unit_rate
          smoke_detectors_with_built_in_isolator_amount smoke_detectors_with_built_in_isolator_notes
          smoke_detectors_wall_mounted_with_built_in_isolator_value smoke_detectors_wall_mounted_with_built_in_isolator_unit_rate
          smoke_detectors_wall_mounted_with_built_in_isolator_amount smoke_detectors_wall_mounted_with_built_in_isolator_notes
          smoke_detectors_with_led_indicators_value smoke_detectors_with_led_indicators_unit_rate
          smoke_detectors_with_led_indicators_amount smoke_detectors_with_led_indicators_notes
          smoke_detectors_with_led_and_built_in_isolator_value smoke_detectors_with_led_and_built_in_isolator_unit_rate
          smoke_detectors_with_led_and_built_in_isolator_amount smoke_detectors_with_led_and_built_in_isolator_notes
          heat_detectors_value heat_detectors_unit_rate heat_detectors_amount heat_detectors_notes
          heat_detectors_with_built_in_isolator_value heat_detectors_with_built_in_isolator_unit_rate
          heat_detectors_with_built_in_isolator_amount heat_detectors_with_built_in_isolator_notes
          high_temperature_heat_detectors_value high_temperature_heat_detectors_unit_rate
          high_temperature_heat_detectors_amount high_temperature_heat_detectors_notes
          heat_rate_of_rise_value heat_rate_of_rise_unit_rate heat_rate_of_rise_amount heat_rate_of_rise_notes
          multi_detectors_value multi_detectors_unit_rate multi_detectors_amount multi_detectors_notes
          multi_detectors_with_built_in_isolator_value multi_detectors_with_built_in_isolator_unit_rate
          multi_detectors_with_built_in_isolator_amount multi_detectors_with_built_in_isolator_notes
          high_sensitive_detectors_for_harsh_environments_value high_sensitive_detectors_for_harsh_environments_unit_rate
          high_sensitive_detectors_for_harsh_environments_amount high_sensitive_detectors_for_harsh_environments_notes
          sensitivity_range_value sensitivity_range_unit_rate sensitivity_range_amount sensitivity_range_notes
          beam_detector_transmitter_value beam_detector_transmitter_unit_rate beam_detector_transmitter_amount beam_detector_transmitter_notes
          beam_detector_receiver_value beam_detector_receiver_unit_rate beam_detector_receiver_amount beam_detector_receiver_notes
          duct_smoke_detectors_value duct_smoke_detectors_unit_rate duct_smoke_detectors_amount duct_smoke_detectors_notes
          flow_switches_interface_module_value flow_switches_interface_module_unit_rate flow_switches_interface_module_amount flow_switches_interface_module_notes
          tamper_switches_interface_module_value tamper_switches_interface_module_unit_rate tamper_switches_interface_module_amount tamper_switches_interface_module_notes
          gas_detectors_value gas_detectors_unit_rate gas_detectors_amount gas_detectors_notes
          flame_detectors_value flame_detectors_unit_rate flame_detectors_amount flame_detectors_notes
          subsystem_id supplier_id
        ],
        manual_pull_stations_attributes: %i[
          id type break_glass break_glass_weather_proof subsystem_id supplier_id
        ],
        door_holders_attributes: %i[
          id total_no_of_devices total_no_of_devices_unit_rate total_no_of_devices_amount total_no_of_devices_notes
          total_no_of_relays total_no_of_relays_unit_rate total_no_of_relays_amount total_no_of_relays_notes
          subsystem_id supplier_id
        ],
        graphic_systems_attributes: %i[
          id workstation workstation_control_feature softwares licenses screens screen_inch color life_span
          no_of_buttons no_of_function antibacterial subsystem_id supplier_id
        ],
        notification_devices_attributes: %i[
          id notification_addressing fire_alarm_strobe fire_alarm_strobe_wp fire_alarm_horn fire_alarm_horn_wp
          fire_alarm_horn_with_strobe fire_alarm_horn_with_strobe_wp subsystem_id supplier_id
        ],
        isolations_attributes: %i[
          id built_in_fault_isolator_for_each_detector built_in_fault_isolator_for_each_mcp_bg
          built_in_fault_isolator_for_each_sounder_horn built_in_fault_isolator_for_monitor_control_modules
          grouping_for_each_12_15 subsystem_id supplier_id
        ],
        connection_betweens_attributes: %i[
          id connection_type network_module cables_for_connection subsystem_id supplier_id
        ],
        interface_with_other_systems_attributes: %i[
          id integration_type1 integration_type2 integration_type3 integration_type4 integration_type5 integration_type6 integration_type7 integration_type8 integration_type9 integration_type10
          total_no_of_control_modules total_no_of_monitor_modules total_no_of_dual_monitor_modules total_no_of_zone_module
          subsystem_id supplier_id
        ],
        evacuation_systems_attributes: %i[
          id included_in_fire_alarm_system evacuation_system_part_of_fa_panel amplifier_power_output total_no_of_amplifiers
          total_no_of_evacuation_speakers_circuits total_no_of_wattage_per_panel fire_rated_speakers_watt
          speakers_tapping_watt total_no_of_speakers subsystem_id supplier_id
        ],
        prerecorded_message_audio_modules_attributes: %i[
          id message_type total_time_for_messages total_no_of_voice_messages message_storage_location master_microphone
          subsystem_id supplier_id
        ],
        telephone_systems_attributes: %i[
          id number_of_firefighter_telephone_circuits_per_panel total_no_of_firefighter_telephone_cabinet
          total_no_of_firefighter_phones total_no_of_firefighter_jacks subsystem_id supplier_id
        ],
        spare_parts_attributes: %i[
          id total_no_of_device1 total_no_of_device2 total_no_of_device3 total_no_of_device4 subsystem_id supplier_id
        ],
        scope_of_works_attributes: %i[
          id supply install supervision_test_commissioning cables_supply cables_size_2cx1_5mm cables_size_2cx2_5mm
          pulling_cables cables_terminations design_review_verification heat_map_study voltage_drop_study_for_initiating_devices_loop
          voltage_drop_notification_circuits battery_calculation cause_and_effect_matrix high_level_riser_diagram shop_drawings
          shop_drawings_verification training_days subsystem_id supplier_id
        ],
        material_and_deliveries_attributes: %i[
          id material_availability delivery_time_period delivery_type delivery_to subsystem_id supplier_id
        ]
      )
    end

    # UPDATED: Include the new parameters in evaluation
    def perform_evaluation(subsystem:, fire_alarm_control_panel:, detectors_field_device:, door_holders:,
                           notification_devices:, isolation_record:, manual_pull_station:,
                           evacuation_systems:, telephone_systems:, general_commercial_data:)
      fire_alarm_results = evaluate_data(fire_alarm_control_panel, :fire_alarm_control_panels)
      detector_results = evaluate_data(detectors_field_device, :detectors_field_devices)
      door_holder_results = evaluate_data(door_holders, :door_holders)
      notification_dev_results = evaluate_data(notification_devices, :notification_devices)
      isolation_results = evaluate_data(isolation_record, :isolations)

      # NEW: Evaluate additional fields
      manual_pull_station_results = evaluate_data(manual_pull_station, :manual_pull_stations)
      evacuation_systems_results = evaluate_data(evacuation_systems, :evacuation_systems)
      telephone_systems_results = evaluate_data(telephone_systems, :telephone_systems)
      general_commercial_results = evaluate_data(general_commercial_data, :general_commercial_data)

      results_hash = {
        fire_alarm_control_panels: fire_alarm_results,
        detectors_field_devices: detector_results,
        door_holders: door_holder_results,
        notification_devices: notification_dev_results,
        isolations: isolation_results,
        manual_pull_stations: manual_pull_station_results,
        evacuation_systems: evacuation_systems_results,
        telephone_systems: telephone_systems_results,
        general_commercial_data: general_commercial_results
      }

      # Merge all items for overall acceptance calculation
      all_items = fire_alarm_results + detector_results + door_holder_results +
                  notification_dev_results + isolation_results +
                  manual_pull_station_results + evacuation_systems_results +
                  telephone_systems_results + general_commercial_results

      total_items = all_items.size
      total_accepted = all_items.sum { |item| item[:is_accepted] } # 1 for accepted, 0 for rejected

      acceptance_percentage = total_items.zero? ? 0 : (total_accepted.to_f / total_items) * 100
      overall_status = acceptance_percentage >= 60 ? 'Accepted' : 'Rejected'

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
        submitted_value = begin
          record.send(field)
        rescue StandardError
          nil
        end
        cell = begin
          standard_sheet[location[:sheet_row]][location[:sheet_column]]
        rescue StandardError
          nil
        end
        standard_value = cell&.value

        is_accepted_boolean = submitted_value.present? &&
                              standard_value.present? &&
                              submitted_value.to_i >= standard_value.to_i
        is_accepted_value = is_accepted_boolean ? 1 : 0

        results << {
          field: field.to_s.humanize,
          submitted_value: submitted_value || 'N/A',
          standard_value: standard_value || 'N/A',
          is_accepted: is_accepted_value
        }
      end

      results
    end

    # def generate_evaluation_report(subsystem, supplier, comparison_results)
    #   file_name = "evaluation_report_#{subsystem.id}_supplier_#{supplier.id}_#{Time.now.to_i}.pdf"
    #   file_path = Rails.root.join('public', 'reports', file_name)

    #   Prawn::Document.generate(file_path) do |pdf|
    #     # 🔹 Add supplier name below the title
    #     pdf.text 'Evaluation Report', size: 30, style: :bold, align: :center
    #     pdf.move_down 10
    #     pdf.text "Supplier: #{supplier.supplier_name}", size: 14, style: :italic, align: :center
    #     pdf.move_down 20

    #     comparison_results.each do |table_name, results|
    #       next unless results.is_a?(Array)

    #       pdf.text "#{table_name.to_s.humanize} Results", size: 20, style: :bold
    #       pdf.move_down 10

    #       table_data = [['Attribute', 'Submitted Value', 'Standard Value', 'Status']]
    #       results.each do |result|
    #         status_text = result[:is_accepted] == 1 ? 'Accepted' : 'Rejected'
    #         table_data << [
    #           result[:field],
    #           result[:submitted_value],
    #           result[:standard_value],
    #           status_text
    #         ]
    #       end

    #       pdf.table(table_data, header: true, position: :center, width: pdf.bounds.width) do
    #         row(0).font_style = :bold
    #         row(0).background_color = 'cccccc'
    #         self.row_colors = %w[f0f0f0 ffffff]
    #       end
    #       pdf.move_down 20
    #     end

    #     overall = comparison_results[:overall_status]
    #     percent = comparison_results[:acceptance_percentage].round(2)

    #     pdf.text "Overall Acceptance: #{percent}%"
    #     pdf.text "Overall Status: #{overall}"
    #   end

    #   file_path.to_s
    # end

    # ---------------------------------------------------------------------
    # STRONG PARAMS (unchanged)
    # ---------------------------------------------------------------------

    def supplier_data_params
      params.require(:supplier_data).permit(
        :supplier_name, :supplier_category, :total_years_in_saudi_market, :similar_projects
      )
    end

    def fire_alarm_control_panel_params
      params.require(:fire_alarm_control_panel).permit(
        :standards, 
        # total_no_of_panels group
        :total_no_of_panels, :total_no_of_panels_unit_rate, :total_no_of_panels_amount, :total_no_of_panels_notes,
        
        # total_number_of_loop_cards group
        :total_number_of_loop_cards, :total_number_of_loop_cards_unit_rate, :total_number_of_loop_cards_amount, :total_number_of_loop_cards_notes,
        
        # total_number_of_circuits_per_card_loop group
        :total_number_of_circuits_per_card_loop, :total_number_of_circuits_per_card_loop_unit_rate, :total_number_of_circuits_per_card_loop_amount, :total_number_of_circuits_per_card_loop_notes,
        
        # total_no_of_loops group
        :total_no_of_loops, :total_no_of_loops_unit_rate, :total_no_of_loops_amount, :total_no_of_loops_notes,
        
        # total_no_of_spare_loops group
        :total_no_of_spare_loops, :total_no_of_spare_loops_unit_rate, :total_no_of_spare_loops_amount, :total_no_of_spare_loops_notes,
        
        # total_no_of_detectors_per_loop group
        :total_no_of_detectors_per_loop, :total_no_of_detectors_per_loop_unit_rate, :total_no_of_detectors_per_loop_amount, :total_no_of_detectors_per_loop_notes,
        
        # spare_no_of_loops_per_panel group
        :spare_no_of_loops_per_panel, :spare_no_of_loops_per_panel_unit_rate, :spare_no_of_loops_per_panel_amount, :spare_no_of_loops_per_panel_notes,
        
        # field without extra cost fields
        :initiating_devices_polarity_insensitivity,
        
        # spare_percentage_per_loop group
        :spare_percentage_per_loop, :spare_percentage_per_loop_unit_rate, :spare_percentage_per_loop_amount, :spare_percentage_per_loop_notes,
        
        # fa_repeater group
        :fa_repeater, :fa_repeater_unit_rate, :fa_repeater_amount, :fa_repeater_notes,
        
        # auto_dialer group
        :auto_dialer, :auto_dialer_unit_rate, :auto_dialer_amount, :auto_dialer_notes,
        
        # dot_matrix_printer group
        :dot_matrix_printer, :dot_matrix_printer_unit_rate, :dot_matrix_printer_amount, :dot_matrix_printer_notes,
        
        # fields without extra cost fields
        :printer_listing,
        :power_standby_24_alarm_5, :power_standby_24_alarm_15,
        
        # internal_batteries_backup_capacity_panel group
        :internal_batteries_backup_capacity_panel, :internal_batteries_backup_capacity_panel_unit_rate, :internal_batteries_backup_capacity_panel_amount, :internal_batteries_backup_capacity_panel_notes,
        
        # external_batteries_backup_time group
        :external_batteries_backup_time, :external_batteries_backup_time_unit_rate, :external_batteries_backup_time_amount, :external_batteries_backup_time_notes,
        
        # foreign keys
        :subsystem_id, :supplier_id
      )
    end
    

    def detectors_field_devices_params
      params.require(:detectors_field_devices).permit(
        smoke_detectors: %i[value unit_rate amount notes],
        smoke_detectors_with_built_in_isolator: %i[value unit_rate amount notes],
        smoke_detectors_wall_mounted_with_built_in_isolator: %i[value unit_rate amount notes],
        smoke_detectors_with_led_indicators: %i[value unit_rate amount notes],
        smoke_detectors_with_led_and_built_in_isolator: %i[value unit_rate amount notes],
        heat_detectors: %i[value unit_rate amount notes],
        heat_detectors_with_built_in_isolator: %i[value unit_rate amount notes],
        high_temperature_heat_detectors: %i[value unit_rate amount notes],
        heat_rate_of_rise: %i[value unit_rate amount notes],
        multi_detectors: %i[value unit_rate amount notes],
        multi_detectors_with_built_in_isolator: %i[value unit_rate amount notes],
        high_sensitive_detectors_for_harsh_environments: %i[value unit_rate amount notes],
        sensitivity_range: %i[value unit_rate amount notes],
        beam_detector_transmitter: %i[value unit_rate amount notes],
        beam_detector_receiver: %i[value unit_rate amount notes],
        duct_smoke_detectors: %i[value unit_rate amount notes],
        flow_switches_interface_module: %i[value unit_rate amount notes],
        tamper_switches_interface_module: %i[value unit_rate amount notes],
        gas_detectors: %i[value unit_rate amount notes],
        flame_detectors: %i[value unit_rate amount notes]
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
        :manufacturer, :submitted_product, { product_certifications: [] },
        :total_years_in_saudi_market, :coo, :com_for_mfacp, :com_for_detectors
      )
    end

    def graphic_systems_params
      params.require(:graphic_systems).permit(
        :workstation,
        :workstation_control_feature,
        :softwares,
        :licenses,
        :screens,
        :screen_inch,
        :color,
        :life_span,
        :no_of_buttons,
        :no_of_function,
        :antibacterial
      )
    end

    def notification_devices_params
      params.require(:notification_devices).permit(
        :notification_addressing,
        :fire_alarm_strobe, :fire_alarm_strobe_unit_rate, :fire_alarm_strobe_amount, :fire_alarm_strobe_notes,
        :fire_alarm_strobe_wp, :fire_alarm_strobe_wp_unit_rate, :fire_alarm_strobe_wp_amount, :fire_alarm_strobe_wp_notes,
        :fire_alarm_horn, :fire_alarm_horn_unit_rate, :fire_alarm_horn_amount, :fire_alarm_horn_notes,
        :fire_alarm_horn_wp, :fire_alarm_horn_wp_unit_rate, :fire_alarm_horn_wp_amount, :fire_alarm_horn_wp_notes,
        :fire_alarm_horn_with_strobe, :fire_alarm_horn_with_strobe_unit_rate, :fire_alarm_horn_with_strobe_amount, :fire_alarm_horn_with_strobe_notes,
        :fire_alarm_horn_with_strobe_wp, :fire_alarm_horn_with_strobe_wp_unit_rate, :fire_alarm_horn_with_strobe_wp_amount, :fire_alarm_horn_with_strobe_wp_notes,
        :subsystem_id, :supplier_id
      )
    end
    

    def isolation_params
      params.require(:isolations).permit(
        :built_in_fault_isolator_for_each_detector,
        :built_in_fault_isolator_for_each_detector_unit_rate,
        :built_in_fault_isolator_for_each_detector_amount,
        :built_in_fault_isolator_for_each_detector_notes,
    
        :built_in_fault_isolator_for_each_mcp_bg,
        :built_in_fault_isolator_for_each_mcp_bg_unit_rate,
        :built_in_fault_isolator_for_each_mcp_bg_amount,
        :built_in_fault_isolator_for_each_mcp_bg_notes,
    
        :built_in_fault_isolator_for_each_sounder_horn,
        :built_in_fault_isolator_for_each_sounder_horn_unit_rate,
        :built_in_fault_isolator_for_each_sounder_horn_amount,
        :built_in_fault_isolator_for_each_sounder_horn_notes,
    
        :built_in_fault_isolator_for_monitor_control_modules,
        :built_in_fault_isolator_for_monitor_control_modules_unit_rate,
        :built_in_fault_isolator_for_monitor_control_modules_amount,
        :built_in_fault_isolator_for_monitor_control_modules_notes,
    
        :grouping_for_each_12_15,
        :grouping_for_each_12_15_unit_rate,
        :grouping_for_each_12_15_amount,
        :grouping_for_each_12_15_notes
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
        :integration_type1,
        :integration_type2,
        :integration_type3,
        :integration_type4,
        :integration_type5,
        :integration_type6,
        :integration_type7,
        :integration_type8,
        :integration_type9,
        :integration_type10,
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
        :fire_rated_speakers_watt,
        :speakers_tapping_watt,
        # cost fields for amplifier_power_output
        :amplifier_power_output, :amplifier_power_output_unit_rate, :amplifier_power_output_amount, :amplifier_power_output_notes,
        # cost fields for total_no_of_amplifiers
        :total_no_of_amplifiers, :total_no_of_amplifiers_unit_rate, :total_no_of_amplifiers_amount, :total_no_of_amplifiers_notes,
        # cost fields for total_no_of_evacuation_speakers_circuits
        :total_no_of_evacuation_speakers_circuits, :total_no_of_evacuation_speakers_circuits_unit_rate, :total_no_of_evacuation_speakers_circuits_amount, :total_no_of_evacuation_speakers_circuits_notes,
        # cost fields for total_no_of_wattage_per_panel
        :total_no_of_wattage_per_panel, :total_no_of_wattage_per_panel_unit_rate, :total_no_of_wattage_per_panel_amount, :total_no_of_wattage_per_panel_notes,
        # cost fields for total_no_of_speakers
        :total_no_of_speakers, :total_no_of_speakers_unit_rate, :total_no_of_speakers_amount, :total_no_of_speakers_notes,
        :subsystem_id, :supplier_id
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
        :number_of_firefighter_telephone_circuits_per_panel_unit_rate,
        :number_of_firefighter_telephone_circuits_per_panel_amount,
        :number_of_firefighter_telephone_circuits_per_panel_notes,
    
        :total_no_of_firefighter_telephone_cabinet,
        :total_no_of_firefighter_telephone_cabinet_unit_rate,
        :total_no_of_firefighter_telephone_cabinet_amount,
        :total_no_of_firefighter_telephone_cabinet_notes,
    
        :total_no_of_firefighter_phones,
        :total_no_of_firefighter_phones_unit_rate,
        :total_no_of_firefighter_phones_amount,
        :total_no_of_firefighter_phones_notes,
    
        :total_no_of_firefighter_jacks,
        :total_no_of_firefighter_jacks_unit_rate,
        :total_no_of_firefighter_jacks_amount,
        :total_no_of_firefighter_jacks_notes,
        
        :subsystem_id, :supplier_id
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
        :cables_size_2cx1_5mm,
        :cables_size_2cx2_5mm,
        :pulling_cables,
        :cables_terminations,
        :supervision_test_commissioning,
        :design_review_verification,
        :heat_map_study,
        :voltage_drop_study_for_initiating_devices_loop,
        :voltage_drop_notification_circuits,
        :battery_calculation,
        :cause_and_effect_matrix,
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
        :advanced_payment_minimum,
        :performance_bond,
        :total_price_excluding_vat
      )
    end
  end
end
