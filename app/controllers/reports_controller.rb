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
  # Excel Report Generation for Single Supplier (Existing)
  #----------------------------------------------------------------
  def generate_excel_report
    supplier = Supplier.find(params[:supplier_id])
    subsystem = Subsystem.find(params[:subsystem_id])

    data_sections = {
      'Supplier Data' => supplier_data(supplier, subsystem),
      'Product Data' => product_data(supplier, subsystem),
      'Fire Alarm Control Panel' => fire_alarm_control_panel(supplier, subsystem),
      'Graphic Systems' => graphic_system(supplier, subsystem),
      'Detectors Field Devices' => detectors_field_device(supplier, subsystem),
      'Manual Pull Station' => manual_pull_station(supplier, subsystem),
      'Door Holders' => door_holder(supplier, subsystem),
      'Notification Devices' => notification_devices(supplier, subsystem),
      'Isolation Data' => isolations(supplier, subsystem),
      'Connection Between FACPs' => connection_betweens(supplier, subsystem),
      'Interface with Other Systems' => interface_with_other_systems(supplier, subsystem),
      'Evacuation Systems' => evacuation_systems(supplier, subsystem),
      'Prerecorded Messages/Audio Module' => prerecorded_message_audio_modules(supplier, subsystem),
      'Telephone System' => telephone_systems(supplier, subsystem),
      'Spare Parts' => spare_parts(supplier, subsystem),
      'Scope of Work (SOW)' => scope_of_works(supplier, subsystem),
      'Material & Delivery' => material_and_deliveries(supplier, subsystem),
      'General & Commercial Data' => general_commercial_data(supplier, subsystem)
    }

    p = Axlsx::Package.new
    wb = p.workbook

    wb.add_worksheet(name: 'Evaluation Data') do |sheet|
      sheet.add_row %w[Attribute Value], b: true
      data_sections.each do |section, data|
        sheet.add_row [section, ''], sz: 12, b: true
        data.each { |key, value| sheet.add_row [key.humanize, value] }
      end
    end

    send_data p.to_stream.read,
              filename: "Evaluation_Data_#{supplier.supplier_name}_#{subsystem.name}.xlsx",
              type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end

  #----------------------------------------------------------------
  # Apple-to-Apple Comparison Report Generation
  #----------------------------------------------------------------
  def generate_comparison_report
    selected_ids = params[:selected_suppliers]
    subsystem_id = params[:subsystem_id]
  
    if selected_ids.blank? || subsystem_id.blank?
      flash[:alert] = 'Please select at least one supplier and a subsystem.'
      redirect_back(fallback_location: apple_to_apple_comparison_reports_path) and return
    end
  
    # Get the selected suppliers.
    suppliers = Supplier.where(id: selected_ids)
    chosen_subsystem_id = subsystem_id.to_i
  
    # Define the sections for comparison.
    sections = {
      'Supplier Data' => ->(supplier, subsystem) { supplier_data(supplier, subsystem) },
      'Product Data' => ->(supplier, subsystem) { product_data(supplier, subsystem) },
      'Fire Alarm Control Panel' => ->(supplier, subsystem) { fire_alarm_control_panel(supplier, subsystem) },
      'Graphic Systems' => ->(supplier, subsystem) { graphic_system(supplier, subsystem) },
      'Detectors Field Devices' => ->(supplier, subsystem) { detectors_field_device(supplier, subsystem) },
      'Manual Pull Station' => ->(supplier, subsystem) { manual_pull_station(supplier, subsystem) },
      'Door Holders' => ->(supplier, subsystem) { door_holder(supplier, subsystem) },
      'Notification Devices' => ->(supplier, subsystem) { notification_devices(supplier, subsystem) },
      'Isolation Data' => ->(supplier, subsystem) { isolations(supplier, subsystem) },
      'Connection Between FACPs' => ->(supplier, subsystem) { connection_betweens(supplier, subsystem) },
      'Interface with Other Systems' => ->(supplier, subsystem) { interface_with_other_systems(supplier, subsystem) },
      'Evacuation Systems' => ->(supplier, subsystem) { evacuation_systems(supplier, subsystem) },
      'Prerecorded Messages/Audio Module' => ->(supplier, subsystem) { prerecorded_message_audio_modules(supplier, subsystem) },
      'Telephone System' => ->(supplier, subsystem) { telephone_systems(supplier, subsystem) },
      'Spare Parts' => ->(supplier, subsystem) { spare_parts(supplier, subsystem) },
      'Scope of Work (SOW)' => ->(supplier, subsystem) { scope_of_works(supplier, subsystem) },
      'Material & Delivery' => ->(supplier, subsystem) { material_and_deliveries(supplier, subsystem) },
      'General & Commercial Data' => ->(supplier, subsystem) { general_commercial_data(supplier, subsystem) }
    }
  
    # Build the comparison data for each section.
    comparison_data = {}
    sections.each do |section_name, fetch_proc|
      # Example: skip these two if you don’t want them in the output
      next if %w[Supplier\ Data Product\ Data].include?(section_name)
  
      section_hash = {}
      suppliers.each do |supplier|
        chosen_subsystem = supplier.approved_subsystems.find_by(id: chosen_subsystem_id)
        data = chosen_subsystem ? fetch_proc.call(supplier, chosen_subsystem) : {}
        data.each do |attr, value|
          section_hash[attr] ||= {}
          # Replace nil/empty with '' instead of 'N/A'
          section_hash[attr][supplier.supplier_name] = value.present? ? value : ''
        end
      end
      comparison_data[section_name] = section_hash unless section_hash.empty?
    end
  
    Rails.logger.info "Comparison Data: #{comparison_data.inspect}"
  
    # Determine file name based on evaluation_type parameter (if still needed).
    evaluation = params[:evaluation_type].to_s.strip
    file_name = case evaluation
                when 'TechnicalOnly'
                  'Technical_Apple_to_Apple.xlsx'
                when 'Technical&Evaluation'
                  'Commercial_Apple_to_Apple.xlsx'
                else
                  'Apple_to_Apple_Comparison.xlsx'
                end
  
    # Generate the Excel workbook.
    p = Axlsx::Package.new
    wb = p.workbook
  
    # --- STYLES ---
    styles = wb.styles
    header_style = styles.add_style(
      bg_color: '4472C4',
      fg_color: 'FFFFFF',
      b: true,
      alignment: { horizontal: :center },
      border: { style: :thin, color: '000000' }
    )
    section_title_style = styles.add_style(
      bg_color: 'D9D9D9',
      fg_color: '000000',
      b: true,
      sz: 12,
      border: { style: :thin, color: '000000' }
    )
    cell_style = styles.add_style(
      border: { style: :thin, color: '000000' },
      alignment: { horizontal: :left }
    )
    supplier_name_style = styles.add_style(
      border: { style: :thin, color: '000000' },
      alignment: { horizontal: :center, vertical: :center },
      b: true
    )
  
    wb.add_worksheet(name: 'Apple to Apple Comparison') do |sheet|
      # Example top row for selected suppliers
      supplier_names = suppliers.map(&:supplier_name).join(', ')
      sheet.add_row ["Selected Suppliers:", supplier_names], style: header_style
      sheet.add_row []  # blank row
    
      comparison_data.each do |section_name, attributes_hash|
        # Section title row
        sheet.add_row [section_name], style: section_title_style
    
        # First header row: "Attribute" + each supplier name across 3 merged columns
        first_header_row = ['Attribute']
        suppliers.each do |supplier|
          first_header_row << supplier.supplier_name
          first_header_row << ''
          first_header_row << ''
        end
        sheet.add_row first_header_row, style: header_style
    
        # ---- Fix the merge_cells usage here ----
        current_row_idx = sheet.rows.size - 1  # the index of the row we just added
        col_start = 1  # we start from column 1 since col 0 is "Attribute"
        suppliers.each do |_supplier|
          # Convert row/col to references like "B2", "D2"
          start_cell_ref = Axlsx::cell_r(current_row_idx, col_start)
          end_cell_ref   = Axlsx::cell_r(current_row_idx, col_start + 2)
          # Merge them
          sheet.merge_cells("#{start_cell_ref}:#{end_cell_ref}")
          col_start += 3
        end
    
        # Second header row: blank under "Attribute" + "Unit Rate", "Amount", "Notes"
        second_header_row = ['']
        suppliers.each do |_supplier|
          second_header_row << 'Unit Rate'
          second_header_row << 'Amount'
          second_header_row << 'Notes'
        end
        sheet.add_row second_header_row, style: header_style
    
        # ... rest of your grouping/row writing logic ...
      end
    end
    
  
    send_data p.to_stream.read,
              filename: file_name,
              type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end
  
  

  def show_comparison_report
    selected_ids = params[:selected_suppliers]
    subsystem_id = params[:subsystem_id]

    if selected_ids.blank? || subsystem_id.blank?
      flash[:alert] = 'Please select at least one supplier and a subsystem.'
      redirect_back(fallback_location: apple_to_apple_comparison_reports_path) and return
    end

    # Fetch the selected suppliers
    suppliers = Supplier.where(id: selected_ids)
    chosen_subsystem_id = subsystem_id.to_i

    # Define the same sections used in generate_comparison_report
    sections = {
      'Supplier Data' => ->(supplier, subsystem) { supplier_data(supplier, subsystem) },
      'Product Data' => ->(supplier, subsystem) { product_data(supplier, subsystem) },
      'Fire Alarm Control Panel' => ->(supplier, subsystem) { fire_alarm_control_panel(supplier, subsystem) },
      'Graphic Systems' => ->(supplier, subsystem) { graphic_system(supplier, subsystem) },
      'Detectors Field Devices' => ->(supplier, subsystem) { detectors_field_device(supplier, subsystem) },
      'Manual Pull Station' => ->(supplier, subsystem) { manual_pull_station(supplier, subsystem) },
      'Door Holders' => ->(supplier, subsystem) { door_holder(supplier, subsystem) },
      'Notification Devices' => ->(supplier, subsystem) { notification_devices(supplier, subsystem) },
      'Isolation Data' => ->(supplier, subsystem) { isolations(supplier, subsystem) },
      'Connection Between FACPs' => ->(supplier, subsystem) { connection_betweens(supplier, subsystem) },
      'Interface with Other Systems' => ->(supplier, subsystem) { interface_with_other_systems(supplier, subsystem) },
      'Evacuation Systems' => ->(supplier, subsystem) { evacuation_systems(supplier, subsystem) },
      'Prerecorded Messages/Audio Module' => lambda { |supplier, subsystem|
        prerecorded_message_audio_modules(supplier, subsystem)
      },
      'Telephone System' => ->(supplier, subsystem) { telephone_systems(supplier, subsystem) },
      'Spare Parts' => ->(supplier, subsystem) { spare_parts(supplier, subsystem) },
      'Scope of Work (SOW)' => ->(supplier, subsystem) { scope_of_works(supplier, subsystem) },
      'Material & Delivery' => ->(supplier, subsystem) { material_and_deliveries(supplier, subsystem) },
      'General & Commercial Data' => ->(supplier, subsystem) { general_commercial_data(supplier, subsystem) }
    }

    # Build the comparison data (just like generate_comparison_report)
    comparison_data = {}
    sections.each do |section_name, fetch_proc|
      section_hash = {}
      suppliers.each do |supplier|
        chosen_subsystem = supplier.approved_subsystems.find_by(id: chosen_subsystem_id)
        data = chosen_subsystem ? fetch_proc.call(supplier, chosen_subsystem) : {}
        data.each do |attr, value|
          section_hash[attr] ||= {}
          section_hash[attr][supplier.supplier_name] = value.present? ? value : 'N/A'
        end
      end
      comparison_data[section_name] = section_hash
    end

    # Store the data for rendering in the view
    @comparison_data = comparison_data
  end

  def evaluation_result
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

    # Separate out the detailed section results and the overall metrics
    @evaluation_results = evaluation_results.reject { |k, _| %i[overall_status acceptance_percentage].include?(k) }
    @overall_status = evaluation_results[:overall_status]
    @acceptance_percentage = evaluation_results[:acceptance_percentage]
  end

  #----------------------------------------------------------------
  # Other Actions (index, evaluation_tech_report, evaluation_data, generate_evaluation_report)
  #----------------------------------------------------------------
  def index
    @suppliers_with_evaluations = Supplier.joins(:supplier_data, :product_data, :detectors_field_devices,
                                                 :general_commercial_data)
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
    redirect_to existing_report and return if existing_report

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

    pdf_content = generate_evaluation_pdf(@subsystem, @supplier, evaluation_results)

    send_data pdf_content,
              filename: "evaluation_report_#{@subsystem.id}_#{@supplier.id}.pdf",
              type: 'application/pdf',
              disposition: 'attachment'
  end

  def apple_to_apple_comparison
    case params[:commit]
    when 'generate'
      if params[:selected_suppliers].blank? || params[:subsystem_id].blank?
        flash[:alert] = 'Please select at least one supplier and a subsystem.'
        redirect_to apple_to_apple_comparison_reports_path and return
      end
      redirect_to generate_comparison_report_reports_path(
        selected_suppliers: params[:selected_suppliers],
        subsystem_id: params[:subsystem_id],
        evaluation_type: params[:evaluation_type]
      ) and return

    when 'show'
      if params[:selected_suppliers].blank? || params[:subsystem_id].blank?
        flash[:alert] = 'Please select at least one supplier and a subsystem.'
        redirect_to apple_to_apple_comparison_reports_path and return
      end
      redirect_to show_comparison_report_reports_path(
        selected_suppliers: params[:selected_suppliers],
        subsystem_id: params[:subsystem_id]
      ) and return

    # If user clicked the new "Filter" button, or is just loading the page
    else
      @subsystem_id = params[:subsystem_id].presence
      # Use the actual association for subsystems if "approved_subsystems" doesn't exist
      evaluation_type = params[:evaluation_type]
      @suppliers_with_subsystems = if evaluation_type.present?
                                     Supplier.where(evaluation_type: evaluation_type).includes(:subsystems)
                                   else
                                     Supplier.includes(:subsystems)
                                   end

    end
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
        record.attributes.except('id', 'subsystem_id', 'created_at', 'updated_at', 'supplier_id').each do |key, value|
          data["#{label_prefix} #{index + 1} - #{key.humanize}"] = value
        end
      end
    elsif association.present?
      association.attributes.except('id', 'subsystem_id', 'created_at', 'updated_at',
                                    'supplier_id').each do |key, value|
        data["#{label_prefix} - #{key.humanize}"] = value
      end
    end
    data
  end

  def supplier_data(supplier, subsystem)
    supplier.attributes.except('id', 'created_at', 'updated_at')
    record = supplier.supplier_data.find_by(subsystem_id: subsystem.id)
    process_association(record, 'Supplier')
  end

  # Methods for evaluation data that require both supplier and subsystem.
  def product_data(supplier, subsystem)
    record = supplier.product_data.find_by(subsystem_id: subsystem.id)
    process_association(record, 'Product')
  end

  def fire_alarm_control_panel(supplier, subsystem)
    record = supplier.fire_alarm_control_panels.find_by(subsystem_id: subsystem.id)
    process_association(record, 'Panel')
  end

  def graphic_system(supplier, subsystem)
    record = supplier.graphic_systems.find_by(subsystem_id: subsystem.id)
    process_association(record, 'Graphic System')
  end

  def detectors_field_device(supplier, subsystem)
    record = supplier.detectors_field_devices.find_by(subsystem_id: subsystem.id)
    process_association(record, 'Detector')
  end

  def manual_pull_station(supplier, subsystem)
    record = supplier.manual_pull_stations.find_by(subsystem_id: subsystem.id)
    process_association(record, 'Manual Pull Station')
  end

  def door_holder(supplier, subsystem)
    record = supplier.door_holders.find_by(subsystem_id: subsystem.id)
    process_association(record, 'Door Holder')
  end

  def notification_devices(supplier, subsystem)
    record = supplier.notification_devices.find_by(subsystem_id: subsystem.id)
    process_association(record, 'Notification Device')
  end

  def isolations(supplier, subsystem)
    record = supplier.isolations.find_by(subsystem_id: subsystem.id)
    process_association(record, 'Isolation')
  end

  def connection_betweens(supplier, subsystem)
    record = supplier.connection_betweens.find_by(subsystem_id: subsystem.id)
    process_association(record, 'Connection')
  end

  def interface_with_other_systems(supplier, subsystem)
    record = supplier.interface_with_other_systems.find_by(subsystem_id: subsystem.id)
    process_association(record, 'Interface')
  end

  def evacuation_systems(supplier, subsystem)
    record = supplier.evacuation_systems.find_by(subsystem_id: subsystem.id)
    process_association(record, 'Evacuation System')
  end

  def prerecorded_message_audio_modules(supplier, subsystem)
    record = supplier.prerecorded_message_audio_modules.find_by(subsystem_id: subsystem.id)
    process_association(record, 'Prerecorded Message/Audio Module')
  end

  def telephone_systems(supplier, subsystem)
    record = supplier.telephone_systems.find_by(subsystem_id: subsystem.id)
    process_association(record, 'Telephone System')
  end

  def spare_parts(supplier, subsystem)
    record = supplier.spare_parts.find_by(subsystem_id: subsystem.id)
    process_association(record, 'Spare Part')
  end

  def scope_of_works(supplier, subsystem)
    record = supplier.scope_of_works.find_by(subsystem_id: subsystem.id)
    process_association(record, 'Scope of Work')
  end

  def material_and_deliveries(supplier, subsystem)
    record = supplier.material_and_deliveries.find_by(subsystem_id: subsystem.id)
    process_association(record, 'Material & Delivery')
  end

  def general_commercial_data(supplier, subsystem)
    record = supplier.general_commercial_data.find_by(subsystem_id: subsystem.id)
    process_association(record, 'General & Commercial')
  end

  def set_suppliers
    supplier_ids = params[:supplier_ids]
    @suppliers = Supplier.where(id: supplier_ids)
  end

  # ------------------------------------------------------------------
  # UPDATED: Fetch standards from S3 (via StandardFile) rather than local
  # ------------------------------------------------------------------
  require 'tempfile'
  require 'rubyXL'

  def fetch_standard_data(sheet_name)
    # 1) Locate the attached Excel file in StandardFile
    doc = StandardFile.first
    unless doc && doc.excel_file.attached?
      Rails.logger.error 'No StandardFile or excel_file attached!'
      return nil
    end

    begin
      # 2) Download the file from S3 into a Tempfile
      temp_file = Tempfile.new(['standards', '.xlsx'])
      temp_file.binmode
      temp_file.write(doc.excel_file.download)
      temp_file.rewind

      # 3) Parse with RubyXL
      standard_workbook = RubyXL::Parser.parse(temp_file.path)
      standard_sheet = standard_workbook.worksheets.find { |ws| ws.sheet_name == sheet_name }
      standard_sheet
    rescue StandardError => e
      Rails.logger.error "Error reading standard data from S3: #{e.message}"
      nil
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  def generate_evaluation_pdf(subsystem, supplier, evaluation_results)
    pdf = Prawn::Document.new
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

    pdf.render
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

  # Compare specific field data with standards from S3
  def compare_field_data(field_name, field_data)
    comparison_result = []
    sheet_name = COMPARISON_FIELDS.dig(field_name, :sheet_name)
    return comparison_result unless sheet_name

    standard_sheet = fetch_standard_data(sheet_name)
    return comparison_result unless standard_sheet

    comparison_fields = COMPARISON_FIELDS[field_name][:fields]
    comparison_fields.each do |field, location|
      submitted_value = field_data&.send(field)
      cell = begin
        standard_sheet[location[:sheet_row]][location[:sheet_column]]
      rescue StandardError
        nil
      end
      standard_value = cell&.value
      is_accepted = submitted_value.to_i >= standard_value.to_i ? 1 : 0

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
