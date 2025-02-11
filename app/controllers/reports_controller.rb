class ReportsController < ApplicationController
  def index
    # Fetch suppliers who have submitted evaluations
    @suppliers_with_evaluations = Supplier.joins(:supplier_data, :product_data, :detectors_field_devices, :general_commercial_data)
                                          .distinct
  end

  def evaluation_tech_report
    # This action will display all suppliers and their subsystems
    @suppliers_with_subsystems = Supplier.joins(:subsystems).distinct
  end

  def evaluation_data
    @supplier = Supplier.find(params[:supplier_id])
    @subsystem = Subsystem.find(params[:subsystem_id])
    
    # Fetching data related to the supplier and subsystem
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
    @supplier_data = @supplier.supplier_data.find_by(subsystem_id: @subsystem.id)

    # Generate evaluation results
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

    # Generate the PDF
    report_path = generate_evaluation_report(@subsystem, @supplier, evaluation_results)

    # Send the file as a download
    send_file report_path, type: 'application/pdf', disposition: 'attachment', filename: "evaluation_report_#{@subsystem.id}_#{@supplier.id}.pdf"
  end

  private

  def generate_excel_report(supplier, supplier_data, product_data, detectors, general_commercial_data)
    @workbook = Axlsx::Package.new
    sheet = @workbook.workbook.add_worksheet(name: 'Evaluation Report')

    # Add header row
    sheet.add_row ['Evaluation Data for Supplier: #{supplier.supplier_name}']
    sheet.add_row ['Supplier Data', 'Product Data', 'Detectors', 'General Commercial Data']

    # Add supplier's evaluation data
    sheet.add_row [supplier_data.supplier_name, product_data.manufacturer, detectors.smoke_detectors, general_commercial_data.warranty_for_materials]

    # Add more rows as necessary based on the data you want to include
  end
end
