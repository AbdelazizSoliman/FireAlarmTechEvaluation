class ReportsController < ApplicationController
  # Only for the tech-report page
  before_action :load_subsystems,               only: [:evaluation_tech_report]
  before_action :load_suppliers_with_subsystems, only: [:evaluation_tech_report]
  # For the actual report and comparison actions
  before_action :load_context, only: [:evaluation_data, :show_comparison_report, :generate_excel_report]

  # GET /reports
  def index
    # Dashboard or links to various report types
  end

  # GET /reports/evaluation_tech_report
  # Renders the subsystem selector + supplier list
  def evaluation_tech_report
  end

  # GET /reports/evaluation_data?supplier_id=…&subsystem_id=…
  # Shows dynamic HTML report for one supplier & subsystem
  def evaluation_data
    @data_by_table = @table_defs.each_with_object({}) do |td, h|
      rec   = fetch_record(td, @supplier, @subsystem)
      attrs = rec&.attributes&.except(*system_cols) || {}
      h[td.table_name] = attrs
    end
  end

  # GET /reports/generate_evaluation_report?supplier_id=…&subsystem_id=…
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

  # Stubs for other actions...
  def evaluation_report;         evaluation_data; render :evaluation_report; end
  def evaluation_result           ; end
  def recommendation               ; end
  def apple_to_apple_comparison    ; end
  def show_comparison_report       ; end
  def generate_comparison_report   ; end
  def sow                          ; end
  def missing_items                ; end
  def differences                  ; end
  def interfaces                   ; end

  private

  # 1) For the tech report form: load subsystems that have any dynamic tables
  def load_subsystems
    ids = TableDefinition.distinct.pluck(:subsystem_id)
    @subsystems = Subsystem.where(id: ids).order(:name)
  end

  # 2) For the tech report form: load only suppliers who submitted for the chosen subsystem
  def load_suppliers_with_subsystems
    if params[:subsystem_id].present?
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
    else
      @suppliers_with_subsystems = Supplier.none
    end
  end

  # 3) For evaluation_data / comparisons: set up context
  def load_context
    @supplier   = Supplier.find(params[:supplier_id])
    @subsystem  = Subsystem.find(params[:subsystem_id])
    @suppliers  = Supplier.where(id: params[:selected_suppliers] || params[:supplier_id])
    @table_defs = TableDefinition.where(subsystem_id: @subsystem.id).order(:position)
  end

  # Dynamically fetch a record from the table defined in td
  def fetch_record(td, supplier, subsystem)
    model = Class.new(ActiveRecord::Base) do
      self.table_name        = td.table_name
      self.inheritance_column = :_type_disabled
    end
    model.find_by(supplier_id: supplier.id, subsystem_id: subsystem.id)
  end

  # Columns to strip out before rendering
  def system_cols
    %w[id created_at updated_at supplier_id subsystem_id]
  end
end
