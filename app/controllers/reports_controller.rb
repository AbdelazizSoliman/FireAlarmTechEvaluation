class ReportsController < ApplicationController

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
    notification_devices: {
      sheet_name: 'Notification Devices',
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
    telephone_systems: {
      sheet_name: 'Telephone System',
      fields: {
        number_of_firefighter_telephone_circuits_per_panel: { sheet_row: 2, sheet_column: 1 },
        total_no_of_firefighter_telephone_cabinet: { sheet_row: 3, sheet_column: 1 },
        total_no_of_firefighter_phones: { sheet_row: 4, sheet_column: 1 },
        total_no_of_firefighter_jacks: { sheet_row: 5, sheet_column: 1 }
      }
    },
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

  #----------------------------------------------------------------
  # Excel Report Generation
  #----------------------------------------------------------------
  def generate_excel_report
    supplier = Supplier.find(params[:supplier_id])
    subsystem = Subsystem.find(params[:subsystem_id])

    data_sections = {
      "Supplier Data"                   => supplier_data(supplier),
      "Product Data"                    => product_data(subsystem),
      "Fire Alarm Control Panel"        => fire_alarm_control_panel(subsystem),
      "Graphic Systems"                 => graphic_system(subsystem),
      "Detectors Field Devices"         => detectors_field_device(subsystem),
      "Manual Pull Station"             => manual_pull_station(subsystem),
      "Door Holders"                    => door_holder(subsystem),
      "Notification Devices"            => notification_devices(subsystem),
      "Isolation Data"                  => isolations(subsystem),
      "Connection Between FACPs"        => connection_betweens(subsystem),
      "Interface with Other Systems"    => interface_with_other_systems(subsystem),
      "Evacuation Systems"              => evacuation_systems(subsystem),
      "Prerecorded Messages/Audio Module" => prerecorded_message_audio_modules(subsystem),
      "Telephone System"                => telephone_systems(subsystem),
      "Spare Parts"                     => spare_parts(subsystem),
      "Scope of Work (SOW)"             => scope_of_works(subsystem),
      "Material & Delivery"             => material_and_deliveries(subsystem),
      "General & Commercial Data"       => general_commercial_data(subsystem)
    }

    p = Axlsx::Package.new
    wb = p.workbook

    wb.add_worksheet(name: "Evaluation Data") do |sheet|
      sheet.add_row ["Attribute", "Value"], b: true
      data_sections.each do |section, data|
        sheet.add_row [section, ""], sz: 12, b: true
        data.each { |key, value| sheet.add_row [key.humanize, value] }
      end
    end

    send_data p.to_stream.read,
              filename: "Evaluation_Data_#{supplier.supplier_name}_#{subsystem.name}.xlsx",
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  #----------------------------------------------------------------
  # Other Actions
  #----------------------------------------------------------------
  def index
    @suppliers_with_evaluations = Supplier.joins(:supplier_data, :product_data, :detectors_field_devices, :general_commercial_data)
                                           .distinct
  end

  def evaluation_tech_report
    @suppliers_with_subsystems = Supplier.joins(:subsystems).distinct
  end

  def evaluation_data
    @supplier = Supplier.find(params[:supplier_id])
    @subsystem = Subsystem.find(params[:subsystem_id])
    data_hash = Digest::SHA256.hexdigest(@supplier.updated_at.to_s + @subsystem.updated_at.to_s)
    report_filename = "evaluation_report_#{@subsystem.id}_supplier_#{@supplier.id}_#{data_hash}.pdf"
    existing_report = Dir["#{Rails.root}/public/reports/#{report_filename}"].first
    if existing_report
      redirect_to existing_report and return
    end

    @supplier_data = @supplier.supplier_data.find_by(subsystem_id: @subsystem.id)
    @product_data = @supplier.product_data.find_by(subsystem_id: @subsystem.id)
    @fire_alarm_control_panel = @supplier.fire_alarm_control_panels.find_by(subsystem_id: @subsystem.id)
    @graphic_system = @supplier.graphic_systems.find_by(subsystem_id: @subsystem.id)
    @detectors_field_device = @supplier.detectors_field_devices.find_by(subsystem_id: @subsystem.id)
    @manual_pull_station = @supplier.manual_pull_stations.find_by(subsystem_id: @subsystem.id)
    @door_holder = @supplier.door_holders.find_by(subsystem_id: @subsystem.id)
    @notification_devices = @supplier.notification_devices.find_by(subsystem_id: @subsystem.id)
    @isolations = @supplier.isolations.find_by(subsystem_id: @subsystem.id)
    @connection_betweens = @supplier.connection_betweens.find_by(subsystem_id: @subsystem.id)
    @interface_with_other_systems = @supplier.interface_with_other_systems.find_by(subsystem_id: @subsystem.id)
    @evacuation_systems = @supplier.evacuation_systems.find_by(subsystem_id: @subsystem.id)
    @prerecorded_message_audio_modules = @supplier.prerecorded_message_audio_modules.find_by(subsystem_id: @subsystem.id)
    @telephone_systems = @supplier.telephone_systems.find_by(subsystem_id: @subsystem.id)
    @spare_parts = @supplier.spare_parts.find_by(subsystem_id: @subsystem.id)
    @scope_of_works = @supplier.scope_of_works.find_by(subsystem_id: @subsystem.id)
    @material_and_deliveries = @supplier.material_and_deliveries.find_by(subsystem_id: @subsystem.id)
    @general_commercial_data = @supplier.general_commercial_data.find_by(subsystem_id: @subsystem.id)
  end

  def generate_evaluation_report
    @supplier = Supplier.find(params[:supplier_id])
    @subsystem = Subsystem.find(params[:subsystem_id])

    evaluation_results = perform_evaluation(
      subsystem: @subsystem,
      fire_alarm_control_panel: @subsystem.fire_alarm_control_panels.find_by(supplier_id: @supplier.id),
      detectors_field_device: @subsystem.detectors_field_devices.find_by(supplier_id: @supplier.id),
      door_holders: @subsystem.door_holders.find_by(supplier_id: @supplier.id),
      notification_devices: @subsystem.notification_devices.find_by(supplier_id: @supplier.id),
      isolation_record: @subsystem.isolations.find_by(supplier_id: @supplier.id),
      manual_pull_station: @subsystem.manual_pull_stations.find_by(supplier_id: @supplier.id),
      evacuation_systems: @subsystem.evacuation_systems.find_by(supplier_id: @supplier.id),
      telephone_systems: @subsystem.telephone_systems.find_by(supplier_id: @supplier.id),
      general_commercial_data: @subsystem.general_commercial_data.find_by(supplier_id: @supplier.id)
    )

    report_path = generate_evaluation_pdf(@subsystem, @supplier, evaluation_results)
    send_file report_path,
              type: 'application/pdf',
              disposition: 'attachment',
              filename: "evaluation_report_#{@subsystem.id}_#{@supplier.id}.pdf"
  end

  def apple_to_apple_comparison
    @suppliers_with_subsystems = Supplier.joins(:subsystems).distinct
  end

  #----------------------------------------------------------------
  # Private Helper Methods
  #----------------------------------------------------------------
  private

  # DRY helper that handles both collections and singular associations.
  def process_association(association, label_prefix)
    data = {}
    if association.respond_to?(:each)
      association.each_with_index do |record, index|
        record.attributes.except("id", "subsystem_id", "created_at", "updated_at", "supplier_id").each do |key, value|
          data["#{label_prefix} #{index + 1} - #{key.humanize}"] = value
        end
      end
    elsif association.present?
      association.attributes.except("id", "subsystem_id", "created_at", "updated_at", "supplier_id").each do |key, value|
        data["#{label_prefix} - #{key.humanize}"] = value
      end
    end
    data
  end

  def supplier_data(supplier)
    supplier.attributes.except("id", "created_at", "updated_at")
  end

  def product_data(subsystem)
    process_association(subsystem.product_data, "Product")
  end

  def fire_alarm_control_panel(subsystem)
    process_association(subsystem.fire_alarm_control_panels, "Panel")
  end

  def graphic_system(subsystem)
    process_association(subsystem.graphic_systems, "Graphic System")
  end

  def detectors_field_device(subsystem)
    process_association(subsystem.detectors_field_devices, "Detector")
  end

  def manual_pull_station(subsystem)
    process_association(subsystem.manual_pull_stations, "Manual Pull Station")
  end

  def door_holder(subsystem)
    process_association(subsystem.door_holders, "Door Holder")
  end

  def notification_devices(subsystem)
    process_association(subsystem.notification_devices, "Notification Device")
  end

  def isolations(subsystem)
    process_association(subsystem.isolations, "Isolation")
  end

  def connection_betweens(subsystem)
    process_association(subsystem.connection_betweens, "Connection")
  end

  def interface_with_other_systems(subsystem)
    process_association(subsystem.interface_with_other_systems, "Interface")
  end

  def evacuation_systems(subsystem)
    process_association(subsystem.evacuation_systems, "Evacuation System")
  end

  def prerecorded_message_audio_modules(subsystem)
    process_association(subsystem.prerecorded_message_audio_modules, "Prerecorded Message/Audio Module")
  end

  def telephone_systems(subsystem)
    process_association(subsystem.telephone_systems, "Telephone System")
  end

  def spare_parts(subsystem)
    process_association(subsystem.spare_parts, "Spare Part")
  end

  def scope_of_works(subsystem)
    process_association(subsystem.scope_of_works, "Scope of Work")
  end

  def material_and_deliveries(subsystem)
    process_association(subsystem.material_and_deliveries, "Material & Delivery")
  end

  def general_commercial_data(subsystem)
    process_association(subsystem.general_commercial_data, "General & Commercial")
  end

  def set_suppliers
    supplier_ids = params[:supplier_ids]
    @suppliers = Supplier.where(id: supplier_ids)
  end

  # Fetch and parse standards data from Excel
  def fetch_standard_data(sheet_name)
    standard_file_path = Rails.root.join('lib', 'standards.xlsx')
    standard_workbook = RubyXL::Parser.parse(standard_file_path)
    standard_workbook.worksheets.find { |ws| ws.sheet_name == sheet_name }
  end

  # Generate PDF based on evaluation results
  def generate_evaluation_pdf(subsystem, supplier, evaluation_results)
    file_name = "evaluation_report_#{subsystem.id}_supplier_#{supplier.id}_#{Time.now.to_i}.pdf"
    file_path = Rails.root.join('public', 'reports', file_name)

    Prawn::Document.generate(file_path) do |pdf|
      pdf.text 'Evaluation Report', size: 30, style: :bold, align: :center
      pdf.move_down 10
      pdf.text "Supplier: #{supplier.supplier_name}", size: 14, style: :italic, align: :center
      pdf.move_down 20

      evaluation_results.each do |table_name, results|
        next unless results.is_a?(Array)

        pdf.text "#{table_name.to_s.humanize} Results", size: 20, style: :bold
        pdf.move_down 10

        table_data = [['Attribute', 'Submitted Value', 'Standard Value', 'Status']]
        results.each do |result|
          status_text = result[:is_accepted] == 1 ? 'Accepted' : 'Rejected'
          table_data << [result[:field], result[:submitted_value], result[:standard_value], status_text]
        end

        pdf.table(table_data, header: true, position: :center, width: pdf.bounds.width) do
          row(0).font_style = :bold
          row(0).background_color = 'cccccc'
          self.row_colors = %w[f0f0f0 ffffff]
        end
        pdf.move_down 20
      end

      overall = evaluation_results[:overall_status]
      percent = evaluation_results[:acceptance_percentage].round(2)

      pdf.text "Overall Acceptance: #{percent}%"
      pdf.text "Overall Status: #{overall}"
    end

    file_path.to_s
  end

  # Perform evaluation based on data and standard comparison
  def perform_evaluation(subsystem:, fire_alarm_control_panel:, detectors_field_device:, door_holders:,
                         notification_devices:, isolation_record:, manual_pull_station:,
                         evacuation_systems:, telephone_systems:, general_commercial_data:)
    comparison_results = {}

    comparison_fields = {
      fire_alarm_control_panels: fire_alarm_control_panel,
      detectors_field_devices: detectors_field_device,
      door_holders: door_holders,
      notification_devices: notification_devices,
      isolations: isolation_record,
      manual_pull_stations: manual_pull_station,
      evacuation_systems: evacuation_systems,
      telephone_systems: telephone_systems,
      general_commercial_data: general_commercial_data
    }

    comparison_fields.each do |field_name, field_data|
      comparison_results[field_name] = compare_field_data(field_name, field_data)
    end

    all_items = comparison_results.values.flatten
    total_items = all_items.size
    total_accepted = all_items.sum { |item| item[:is_accepted] }
    acceptance_percentage = total_items.zero? ? 0 : (total_accepted.to_f / total_items) * 100
    overall_status = acceptance_percentage >= 60 ? 'Accepted' : 'Rejected'

    comparison_results[:overall_status] = overall_status
    comparison_results[:acceptance_percentage] = acceptance_percentage

    comparison_results
  end

  # Compare specific field data with standards
  def compare_field_data(field_name, field_data)
    comparison_result = []
    sheet_name = COMPARISON_FIELDS.dig(field_name, :sheet_name)
    return comparison_result unless sheet_name

    standard_sheet = fetch_standard_data(sheet_name)
    return comparison_result unless standard_sheet

    comparison_fields = COMPARISON_FIELDS[field_name][:fields]
    comparison_fields.each do |field, location|
      submitted_value = field_data&.send(field)
      standard_value = standard_sheet[location[:sheet_row]][location[:sheet_column]].value
      is_accepted = (submitted_value.to_i >= standard_value.to_i) ? 1 : 0

      comparison_result << {
        field: field.to_s.humanize,
        submitted_value: submitted_value || 'N/A',
        standard_value: standard_value || 'N/A',
        is_accepted: is_accepted
      }
    end

    comparison_result
  end

end
