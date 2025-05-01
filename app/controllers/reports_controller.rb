class ReportsController < ApplicationController
  # Load suppliers list for the "Generate Evaluation/Tech Report" page
  before_action :load_suppliers_with_subsystems, only: [:evaluation_tech_report]
  # Load context for dynamic evaluation and comparison
  before_action :load_context, only: [:evaluation_data, :show_comparison_report, :generate_excel_report]

  # GET /reports
  def index
    # You can list summary or links to available reports here
  end

  # GET /reports/evaluation_tech_report
  # Renders the form to select suppliers and subsystem
  def evaluation_tech_report
    # @suppliers_with_subsystems set by before_action
  end

  # GET /reports/evaluation_data?supplier_id=...&subsystem_id=...
  # Shows dynamic HTML report for a single supplier/subsystem
  def evaluation_data
    @data_by_table = @table_defs.each_with_object({}) do |td, h|
      rec   = fetch_record(td, @supplier, @subsystem)
      attrs = rec&.attributes&.except(*system_cols) || {}
      h[td.table_name] = attrs
    end
  end

  # GET /reports/generate_evaluation_report?supplier_id=...&subsystem_id=...
  # Streams an Excel file of the evaluation data
  def generate_excel_report
    p  = Axlsx::Package.new
    wb = p.workbook

    wb.add_worksheet(name: 'Evaluation Data') do |sheet|
      sheet.add_row ['Section', 'Attribute', 'Value'], b: true

      @table_defs.each do |td|
        sheet.add_row [td.table_name.titleize, nil, nil], b: true

        rec   = fetch_record(td, @supplier, @subsystem)
        attrs = rec&.attributes&.except(*system_cols) || {}

        attrs.each do |col, val|
          display = val.is_a?(Array) ? val.join(', ') : val
          sheet.add_row [nil, col.humanize, display.to_s]
        end

        sheet.add_row []
      end
    end

    filename = "Evaluation_#{@supplier.supplier_name}_#{@subsystem.name}.xlsx"
    send_data p.to_stream.read,
      filename: filename,
      type:    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end

  # GET /reports/evaluation_report
  # Alias or legacy action if needed
  def evaluation_report
    evaluation_data
    render :evaluation_report
  end

  # GET /reports/evaluation_result?supplier_id=...&subsystem_id=...
  # Dynamic evaluation data display for any subsystem tables
  def evaluation_result
    @supplier = Supplier.find(params[:supplier_id])
    @subsystem = Subsystem.find(params[:subsystem_id])

    # For each table defined under this subsystem, fetch the record and its attributes
    @evaluation_results = @table_defs.each_with_object({}) do |td, h|
      rec   = fetch_record(td, @supplier, @subsystem)
      attrs = rec&.attributes&.except(*system_cols) || {}
      h[td.table_name] = attrs
    end

    # Optionally, compute overall metrics if you have a generic evaluation helper
    # total_fields = @evaluation_results.values.sum(&:size)
    # filled_fields = @evaluation_results.values.map(&:values).flatten.compact.size
    # @acceptance_percentage = total_fields.positive? ? (filled_fields.to_f/total_fields*100).round(2) : 0
    # @overall_status = @acceptance_percentage >= 60 ? 'Accepted' : 'Rejected'

    # Render the dynamic evaluation_result view
    render :evaluation_result
  end

  # GET /reports/recommendation
  def recommendation
    # TODO: implement recommendation logic
  end

  # GET /reports/apple_to_apple_comparison
  # Renders form to select multiple suppliers and subsystem
  def apple_to_apple_comparison
    # @suppliers_with_subsystems set by before_action if needed
  end

  # GET /reports/show_comparison_report?selected_suppliers[]=...&subsystem_id=...
  # Shows dynamic HTML comparison table
  def show_comparison_report
    @comparison_data = @table_defs.each_with_object({}) do |td, out|
      out[td.table_name] = @suppliers.map do |sup|
        rec   = fetch_record(td, sup, @subsystem)
        attrs = rec&.attributes&.except(*system_cols) || {}
        [sup.supplier_name, attrs]
      end.to_h
    end
  end

  # GET /reports/generate_comparison_report?selected_suppliers[]=...&subsystem_id=...
  def generate_comparison_report
    # TODO: implement Excel/PDF download for comparison, similar to generate_excel_report
  end

  # GET /reports/sow
  def sow
    # TODO: SOW logic
  end

  # GET /reports/missing_items
  def missing_items
    # TODO: Missing items logic
  end

  # GET /reports/differences
  def differences
    # TODO: Differences logic
  end

  # GET /reports/interfaces
  def interfaces
    # TODO: Interfaces logic
  end

  private

  # Loads suppliers (and optionally filters by subsystem)
  # Builds @suppliers_with_subsystems based on which suppliers have submitted any data for the given subsystem
  def load_suppliers_with_subsystems
    return (@suppliers_with_subsystems = Supplier.none) unless params[:subsystem_id].present?
    sid = params[:subsystem_id].to_i
    # Get all table definitions for this subsystem
    table_defs = TableDefinition.where(subsystem_id: sid)
    # For each table, collect supplier_ids that have submissions
    supplier_ids = table_defs.flat_map do |td|
      model = Class.new(ActiveRecord::Base) do
        self.table_name        = td.table_name
        self.inheritance_column = :_type_disabled
      end
      model.where(subsystem_id: sid).pluck(:supplier_id)
    end.uniq.compact
    @suppliers_with_subsystems = Supplier.where(id: supplier_ids)
  end
  end

  # Load common context for dynamic actions
  def load_context
    @supplier   = Supplier.find(params[:supplier_id])
    @subsystem  = Subsystem.find(params[:subsystem_id])
    @suppliers  = Supplier.where(id: params[:selected_suppliers] || params[:supplier_id])
    @table_defs = TableDefinition.where(subsystem_id: @subsystem.id).order(:position)
  end

  # Fetch one record from a dynamic table via TableDefinition
  def fetch_record(td, supplier, subsystem)
    model = Class.new(ActiveRecord::Base) do
      self.table_name        = td.table_name
      self.inheritance_column = :_type_disabled
    end
    model.find_by(supplier_id: supplier.id, subsystem_id: subsystem.id)
  end

  # Columns to strip from each record
  def system_cols
    %w[id created_at updated_at supplier_id subsystem_id]
  end

  # Example helper, adjust signature if needed
  def perform_evaluation(**kwargs)
    # TODO: reuse existing comparison logic or keep your old method
    {}
  end
end
