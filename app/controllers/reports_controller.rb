# app/controllers/reports_controller.rb
class ReportsController < ApplicationController
  # Only for the tech-report page
  before_action :load_subsystems,               only: [:evaluation_tech_report]
  before_action :load_suppliers_with_subsystems, only: [:evaluation_tech_report]
  # For the actual evaluation_data, comparison, and Excel download
  before_action :load_context, only: [:evaluation_data, :show_comparison_report, :generate_excel_report]

  # GET /reports
  def index
    # e.g. render a dashboard of links to your various reports
  end

  # GET /reports/evaluation_tech_report
  # Renders the subsystem selector + supplier list
  def evaluation_tech_report
  end

  # GET /reports/evaluation_data?supplier_id=…&subsystem_id=…
  # Shows the dynamic HTML report for one supplier + subsystem
  def evaluation_data
    @data_by_table = @table_defs.each_with_object({}) do |td, h|
      rec   = fetch_record(td, @supplier, @subsystem)
      attrs = rec&.attributes&.except(*system_cols) || {}
      h[td.table_name] = attrs
    end
  end

  # GET /reports/generate_evaluation_report?supplier_id=…&subsystem_id=…
  # Streams an Excel of that same data
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

  # Stubbed/mirrored legacy actions (no changes needed unless you implement them)
  def evaluation_report;         evaluation_data; render :evaluation_report; end
  def evaluation_result;         end
  def recommendation;            end
  def apple_to_apple_comparison; end
  def show_comparison_report;    end
  def generate_comparison_report;end
  def sow;                       end
  def missing_items;             end
  def differences;               end
  def interfaces;                end

  private

  # 1) Populate @subsystems with only those subsystems
  #    that have *dynamic* tables (static: false)
  def load_subsystems
    subsystem_ids = TableDefinition
                      .where(static: false)
                      .distinct
                      .pluck(:subsystem_id)
    @subsystems = Subsystem.where(id: subsystem_ids).order(:name)
  end

  # 2) Populate @suppliers_with_subsystems: only suppliers
  #    who have actual submissions in those dynamic tables
  def load_suppliers_with_subsystems
    if params[:subsystem_id].present?
      sid        = params[:subsystem_id].to_i
      # only dynamic definitions
      table_defs = TableDefinition.where(subsystem_id: sid, static: false)

      supplier_ids = table_defs.flat_map do |td|
        # spin up an anonymous AR model for each table
        model = Class.new(ActiveRecord::Base) do
          self.table_name        = td.table_name
          self.inheritance_column = :_type_disabled
        end
        # only query if those columns actually exist
        if model.column_names.include?('supplier_id') &&
           model.column_names.include?('subsystem_id')
          model.where(subsystem_id: sid).pluck(:supplier_id)
        else
          []
        end
      end.uniq.compact

      @suppliers_with_subsystems = Supplier.where(id: supplier_ids)
    else
      @suppliers_with_subsystems = Supplier.none
    end
  end

  # 3) Shared context for evaluation_data & comparisons
  def load_context
    @supplier   = Supplier.find(params[:supplier_id])
    @subsystem  = Subsystem.find(params[:subsystem_id])
    @suppliers  = Supplier.where(id: params[:selected_suppliers] || params[:supplier_id])
    @table_defs = TableDefinition.where(subsystem_id: @subsystem.id).order(:position)
  end

  # Dynamically fetch the one record for (table, supplier, subsystem)
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
