# app/controllers/reports_controller.rb
class ReportsController < ApplicationController
  # For both the Tech and Apple-to-Apple forms:
  before_action :load_subsystems,               only: [:evaluation_tech_report, :apple_to_apple_comparison]
  before_action :load_suppliers_with_subsystems, only: [:evaluation_tech_report, :apple_to_apple_comparison]

  # For rendering or downloading any individual/subset report:
  before_action :load_context, only: [:evaluation_data, :show_comparison_report, :generate_excel_report]

  # GET /reports
  def index
    # Dashboard or links to report types...
  end

  # — Single-supplier Tech Report Form —
  # GET /reports/evaluation_tech_report
  def evaluation_tech_report
  end

  # — Single-supplier Data Display —
  # GET /reports/evaluation_data?supplier_id=…&subsystem_id=…
  def evaluation_data
    @data_by_table = @table_defs.each_with_object({}) do |td, h|
      rec   = fetch_record(td, @supplier, @subsystem)
      attrs = rec&.attributes&.except(*system_cols) || {}
      h[td.table_name] = attrs
    end
  end

  # — Single-supplier Excel Download —
  # GET /reports/generate_evaluation_report?supplier_id=…&subsystem_id=…
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

  # — Apple-to-Apple Comparison Form —
  # GET /reports/apple_to_apple_comparison
  def apple_to_apple_comparison
  end

  # — Multi-supplier Comparison Display —
  # GET /reports/show_comparison_report?selected_suppliers[]=…&subsystem_id=…
  def show_comparison_report
    @comparison_data = @table_defs.each_with_object({}) do |td, out|
      out[td.table_name] = @suppliers.map do |sup|
        rec   = fetch_record(td, sup, @subsystem)
        attrs = rec&.attributes&.except(*system_cols) || {}
        [sup.supplier_name, attrs]
      end.to_h
    end
  end

  # — Multi-supplier Excel/PDF Download —
  # GET /reports/generate_comparison_report?selected_suppliers[]=…&subsystem_id=…
  def generate_comparison_report
    # TODO: mirror generate_excel_report logic here
  end

  # (Other legacy stubs…)
  def evaluation_report;         evaluation_data; render :evaluation_report; end
  def evaluation_result;         end
  def recommendation;            end
  def sow;                       end
  def missing_items;             end
  def differences;               end
  def interfaces;                end

  private

  # Load all subsystems for the dropdown
  def load_subsystems
    @subsystems = Subsystem.order(:name)
  end

  # Load only those suppliers who have data for the chosen subsystem
  def load_suppliers_with_subsystems
    if params[:subsystem_id].present?
      sid        = params[:subsystem_id].to_i
      table_defs = TableDefinition.where(subsystem_id: sid)

      supplier_ids = table_defs.flat_map do |td|
        model = Class.new(ActiveRecord::Base) do
          self.table_name        = td.table_name
          self.inheritance_column = :_type_disabled
        end
        if model.column_names.include?('supplier_id') && model.column_names.include?('subsystem_id')
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

  # Shared setup for evaluation_data & comparison actions
  def load_context
    @supplier   = Supplier.find(params[:supplier_id])
    @subsystem  = Subsystem.find(params[:subsystem_id])
    @suppliers  = Supplier.where(id: params[:selected_suppliers] || params[:supplier_id])
    @table_defs = TableDefinition.where(subsystem_id: @subsystem.id).order(:position)
  end

  # Fetch exactly one record for a given table/supplier/subsystem
  def fetch_record(td, supplier, subsystem)
    model = Class.new(ActiveRecord::Base) do
      self.table_name        = td.table_name
      self.inheritance_column = :_type_disabled
    end
    model.find_by(supplier_id: supplier.id, subsystem_id: subsystem.id)
  end

  # Columns to strip before displaying
  def system_cols
    %w[id created_at updated_at supplier_id subsystem_id]
  end
end
