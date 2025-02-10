class ComparisonsController < ApplicationController
  before_action :authenticate_user!

  def index
    # This will load the suppliers that have already submitted evaluations.
    @registration_types = Supplier.distinct.pluck(:registration_type) # Example for filtering by registration type
    @suppliers = Supplier.joins(:subsystems).distinct.where.not(id: nil) # Get suppliers who have data submitted
  end

  def generate
    selected_supplier_ids = params[:supplier_ids] || []
    registration_type = params[:registration_type] # If you need to filter by registration type

    @suppliers = Supplier.where(id: selected_supplier_ids)
    @registration_type = registration_type
    # Filter by registration_type if needed
    @suppliers = @suppliers.where(registration_type: registration_type) if registration_type.present?

    # Gather evaluation data for each supplier
    @evaluation_data = load_evaluation_data(@suppliers)
  end

  def export
    selected_supplier_ids = params[:supplier_ids] || []
    @suppliers = Supplier.where(id: selected_supplier_ids)

    # Assuming you use Axlsx to create Excel
    @workbook = Axlsx::Package.new
    @sheet = @workbook.workbook.add_worksheet(name: 'Comparison')

    # Generate Excel content (we'll create a simple version)
    add_comparison_data_to_excel(@sheet, @suppliers)

    # Send the generated Excel file
    send_data @workbook.to_stream.read, filename: 'apple_to_apple_comparison.xlsx', type: 'application/xlsx',
                                        disposition: 'attachment'
  end

  private

  def load_evaluation_data(suppliers)
    # This method will gather the evaluation data for each supplier and return it
    # You can adjust this according to your data structure

    evaluation_data = {}

    suppliers.each do |supplier|
      # Assuming each supplier has related data like `supplier_data`, `product_data`, etc.
      evaluation_data[supplier.id] = {
        supplier_data: supplier.supplier_data,
        product_data: supplier.product_data
        # Add other data related to the evaluation
      }
    end

    evaluation_data
  end

  def add_comparison_data_to_excel(sheet, suppliers)
    sheet.add_row ['Attribute'] + suppliers.map(&:supplier_name) # Add headers for suppliers

    # Example of "Fire Alarm Control Panel" data. Adjust it according to your evaluation fields.
    attributes = ['Total No. of Panels', 'Total No. of Loop Cards'] # Define the attributes you want to compare

    attributes.each do |attribute|
      row = [attribute]

      suppliers.each do |supplier|
        # Assuming each supplier has relevant evaluation data (e.g., fire_alarm_control_panels)
        value = supplier.fire_alarm_control_panels.first&.send(attribute.downcase.gsub(' ', '_'))
        row << (value || 'N/A')
      end

      sheet.add_row row
    end
  end
end
