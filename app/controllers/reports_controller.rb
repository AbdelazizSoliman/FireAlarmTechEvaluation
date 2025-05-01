class ReportsController < ApplicationController
  # Load suppliers list for the "Generate Evaluation/Tech Report" page
  before_action :load_suppliers_with_subsystems, only: [:evaluation_tech_report]
  # Load context for dynamic evaluation and comparison
  before_action :load_context, only: [:evaluation_data, :show_comparison_report, :generate_excel_report]

  # GET /reports
  def index
    # Summary or navigation for different report types
  end

  # GET /reports/evaluation_tech_report
  # Renders form to select suppliers & subsystem
  def evaluation_tech_report
    # @suppliers_with_subsystems set by before_action
  end

  # GET /reports/evaluation_data?supplier_id=...&subsystem_id=...
  # Dynamic HTML report for one supplier/subsystem
  def evaluation_data
    @data_by_table = @table_defs.each_with_object({}) do |td, h|
      rec   = fetch_record(td, @supplier, @subsystem)
      attrs = rec&.attributes&.except(*system_cols) || {}
      h[td.table_name] = attrs
    end
  end

  # GET /reports/generate_evaluation_report?supplier_id=...&subsystem_id=...
  # Streams an Excel download of the evaluation data
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
  # Legacy alias if still used
  def evaluation_report
    evaluation_data
    render :evaluation_report
  end

  # GET /reports/evaluation_result?supplier_id=...&subsystem_id=...
  # Dynamic evaluation result view for any subsystem
  def evaluation_result
    @supplier = Supplier.find(params[:supplier_id])
    @subsystem = Subsystem.find(params[:subsystem_id])

    @evaluation_results = @table_defs.each_with_object({}) do |td, h|
      rec   = fetch_record(td, @supplier, @subsystem)
      attrs = rec&.attributes&.except(*system_cols) || {}
      h[td.table_name] = attrs
    end

    render :evaluation_result
  end

  # GET /reports/recommendation
  def recommendation
    # TODO: recommendation logic
  end

  # GET /reports/apple_to_apple_comparison
  def apple_to_apple_comparison
    # render form for multi-supplier comparison
  end

  # GET /reports/show_comparison_report?selected_suppliers[]=...&subsystem_id=...
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
    # TODO: implement comparison Excel/PDF
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

  # Builds @suppliers_with_subsystems for the tech report form
  def load_suppliers_with_subsystems
    return (@suppliers_with_subsystems = Supplier.none) unless params[:subsystem_id].present?
    sid        = params[:subsystem_id].to_i
    table_defs = TableDefinition.where(subsystem_id: sid)

    supplier_ids = table_defs.flat_map do |td|
      model = Class.new(ActiveRecord::Base) do
        self.table_name        = td.table_name
        self.inheritance_column = :_type_disabled
      end
      model.where(subsystem_id: sid).pluck(:supplier_id)
    end.uniq.compact

    @suppliers_with_subsystems = Supplier.where(id: supplier_ids)
  end

  # Sets @supplier, @subsystem, @suppliers, and @table_defs for dynamic actions
  def load_context
    @supplier   = Supplier.find(params[:supplier_id])
    @subsystem  = Subsystem.find(params[:subsystem_id])
    @suppliers  = Supplier.where(id: params[:selected_suppliers] || params[:supplier_id])
    @table_defs = TableDefinition.where(subsystem_id: @subsystem.id).order(:position)
  end

  # Fetch a single evaluation record for a table, supplier, and subsystem
  def fetch_record(td, supplier, subsystem)
    model = Class.new(ActiveRecord::Base) do
      self.table_name        = td.table_name
      self.inheritance_column = :_type_disabled
    end
    model.find_by(supplier_id: supplier.id, subsystem_id: subsystem.id)
  end

  # System columns to exclude from attribute hashes
  def system_cols
    %w[id created_at updated_at supplier_id subsystem_id]
  end

  # Stub for any generic evaluation calculations
  def perform_evaluation(**_kwargs)
    {}
  end
end
