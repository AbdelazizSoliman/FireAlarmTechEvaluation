# app/controllers/reports_controller.rb
class ReportsController < ApplicationController
  before_action :load_context, only: %i[evaluation_data show_comparison_report generate_excel_report]

  # Single‐supplier, dynamic HTML view
  def evaluation_data
    @data_by_table = @table_defs.each_with_object({}) do |td, h|
      rec    = fetch_record(td, @supplier, @subsystem)
      attrs  = rec&.attributes&.except(*system_cols) || {}
      h[td.table_name] = attrs
    end
    render :evaluation_data
  end

  # Multi‐supplier, dynamic HTML comparison
  def show_comparison_report
    @comparison_data = @table_defs.each_with_object({}) do |td, out|
      out[td.table_name] = @suppliers.map { |sup|
        rec   = fetch_record(td, sup, @subsystem)
        attrs = rec&.attributes&.except(*system_cols) || {}
        [sup.supplier_name, attrs]
      }.to_h
    end
    render :show_comparison_report
  end

  # Dynamic Excel download for single supplier
  def generate_excel_report
    p  = Axlsx::Package.new
    wb = p.workbook

    wb.add_worksheet(name: 'Evaluation Data') do |sheet|
      # Header row
      sheet.add_row ['Section', 'Attribute', 'Value'], b: true

      @table_defs.each do |td|
        # Section title
        sheet.add_row [td.table_name.titleize, nil, nil], b: true

        rec   = fetch_record(td, @supplier, @subsystem)
        attrs = rec&.attributes&.except(*system_cols) || {}

        attrs.each do |col, val|
          # array values as comma-joined
          display = val.is_a?(Array) ? val.join(', ') : val
          sheet.add_row [nil, col.humanize, display.to_s]
        end

        sheet.add_row []  # blank line
      end
    end

    filename = "Evaluation_#{@supplier.supplier_name}_#{@subsystem.name}.xlsx"
    send_data p.to_stream.read,
      filename: filename,
      type:    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end

  private

  def load_context
    @supplier   = Supplier.find(params[:supplier_id])
    @subsystem  = Subsystem.find(params[:subsystem_id])
    @suppliers  = Supplier.where(id: params[:selected_suppliers] || params[:supplier_id])
    @table_defs = TableDefinition.where(subsystem_id: @subsystem.id).order(:position)
  end

  def fetch_record(td, supplier, subsystem)
    model = Class.new(ActiveRecord::Base) do
      self.table_name        = td.table_name
      self.inheritance_column = :_type_disabled
    end
    model.find_by(supplier_id: supplier.id, subsystem_id: subsystem.id)
  end

  def system_cols
    %w[id created_at updated_at supplier_id subsystem_id]
  end
end
