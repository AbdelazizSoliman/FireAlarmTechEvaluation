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
    # Find the supplier by ID
    @supplier = Supplier.find(params[:supplier_id])
    @subsystem = Subsystem.find(params[:subsystem_id])


    # Gather all the related evaluation data for the selected supplier
    @supplier_data = @supplier.supplier_data
    @product_data = @supplier.product_data
    @detectors = @supplier.detectors_field_devices
    @general_commercial_data = @supplier.general_commercial_data

    # You can add more data as needed from other tables like `evacuation_systems`, `fire_alarm_control_panels`, etc.
  end

  def generate_evaluation_report
    # Generate the evaluation report for the supplier
    @supplier = Supplier.find(params[:supplier_id])
    @supplier_data = @supplier.supplier_data
    @product_data = @supplier.product_data
    @detectors = @supplier.detectors_field_devices
    @general_commercial_data = @supplier.general_commercial_data

    # Generate Excel report (adjust as necessary for your data)
    generate_excel_report(@supplier, @supplier_data, @product_data, @detectors, @general_commercial_data)

    # Send the generated report as an Excel file
    send_data @workbook.to_stream.read, filename: 'evaluation_report.xlsx', type: 'application/xlsx', disposition: 'attachment'
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
