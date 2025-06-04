class ReportsController < ApplicationController
  # Only for the Tech/Apple-to-Apple _forms_
  before_action :load_subsystems, only: [:evaluation_tech_report, :apple_to_apple_comparison, :evaluation_result_comparison_form]
  before_action :load_suppliers_with_subsystems, only: [:evaluation_tech_report, :apple_to_apple_comparison, :evaluation_result_comparison_form]

  # Single‐supplier report (HTML & Excel)
  before_action :load_single_context, only: [:evaluation_data, :generate_evaluation_report]

  # Multi‐supplier comparison (HTML & Excel)
  before_action :load_multi_context, only: [:show_comparison_report, :generate_comparison_report]

  # GET /reports
  def index
    # your dashboard / links
  end

  # — Tech Form —
  # GET /reports/evaluation_tech_report
  def evaluation_tech_report; end

  # — Apple-to-Apple Form —
  # GET /reports/apple_to_apple_comparison
  def apple_to_apple_comparison; end

  # — New: Comparison Form —
  # GET /reports/evaluation_result_comparison_form
  def evaluation_result_comparison_form
    @subsystems = Subsystem.all.order(:name)

    if params[:subsystem_id].present?
      @suppliers_with_subsystems = Supplier
        .joins(:evaluation_results)
        .where(evaluation_results: { subsystem_id: params[:subsystem_id] })
        .distinct
    else
      @suppliers_with_subsystems = []
    end
  end

  # — Single‐supplier HTML —
  def evaluation_data
    @data_by_table = @table_defs.each_with_object({}) do |td, h|
      rec = fetch_record(td, @supplier, @subsystem)
      attrs = rec&.attributes&.except(*system_cols) || {}
      h[td.table_name] = attrs
    end
  end

  # — Single‐supplier Excel —
  def generate_evaluation_report
    pkg = Axlsx::Package.new
    wb = pkg.workbook
    groups = @table_defs.group_by(&:parent_table)

    wb.add_worksheet(name: 'Evaluation Data') do |sheet|
      sheet.add_row ['Section/Table', 'Attribute', 'Value'], b: true

      (groups[nil] || []).each do |parent_td|
        sheet.add_row [parent_td.table_name.titleize, nil, nil], b: true
        children = groups[parent_td.table_name] || []

        if children.any?
          children.each do |child_td|
            sheet.add_row ["  ↳ #{child_td.table_name.titleize}", nil, nil], b: true
            rec = fetch_record(child_td, @supplier, @subsystem)
            attrs = (rec&.attributes || {}).except(*system_cols, 'parent_id')

            attrs.each do |col, val|
              sheet.add_row [nil, col.humanize, val.is_a?(Array) ? val.join(', ') : val.to_s]
            end
            sheet.add_row []
          end
        else
          rec = fetch_record(parent_td, @supplier, @subsystem)
          attrs = (rec&.attributes || {}).except(*system_cols, 'parent_id')

          attrs.each do |col, val|
            sheet.add_row [nil, col.humanize, val.is_a?(Array) ? val.join(', ') : val.to_s]
          end
          sheet.add_row []
        end
      end
    end

    filename = "Evaluation_#{@supplier.supplier_name}_#{@subsystem.name}.xlsx"
    send_data pkg.to_stream.read, filename: filename, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end

  # — Multi‐supplier HTML —
  def show_comparison_report
    @comparison_data = @table_defs.each_with_object({}) do |td, out|
      out[td.table_name] = @suppliers.map do |sup|
        rec = fetch_record(td, sup, @subsystem)
        attrs = rec&.attributes&.except(*system_cols) || {}
        [sup.supplier_name, attrs]
      end.to_h
    end
  end

  # — Multi‐supplier Excel —
  def generate_comparison_report
    pkg = Axlsx::Package.new
    wb = pkg.workbook
    groups = @table_defs.group_by(&:parent_table)

    wb.add_worksheet(name: 'Comparison') do |sheet|
      header = ['Attribute'] + @suppliers.map(&:supplier_name)
      sheet.add_row header, b: true

      (groups[nil] || []).each do |parent_td|
        sheet.add_row [parent_td.table_name.titleize] + [''] * @suppliers.size, b: true
        children = groups[parent_td.table_name] || []

        if children.any?
          children.each do |child_td|
            sheet.add_row ["↳ #{child_td.table_name.titleize}"] + [''] * @suppliers.size, b: true
            hashes = @suppliers.map { |sup| fetch_record(child_td, sup, @subsystem)&.attributes&.except(*system_cols, 'parent_id') || {} }
            keys = hashes.flat_map(&:keys).uniq.sort

            keys.each do |col|
              row = [col.humanize] + hashes.map { |h| h[col].is_a?(Array) ? h[col].join(', ') : h[col].to_s }
              sheet.add_row row
            end
            sheet.add_row []
          end
        else
          hashes = @suppliers.map { |sup| fetch_record(parent_td, sup, @subsystem)&.attributes&.except(*system_cols, 'parent_id') || {} }
          keys = hashes.flat_map(&:keys).uniq.sort

          keys.each do |col|
            row = [col.humanize] + hashes.map { |h| h[col].is_a?(Array) ? h[col].join(', ') : h[col].to_s }
            sheet.add_row row
          end
          sheet.add_row []
        end
      end
    end

    filename = "Comparison_#{@subsystem.name.parameterize}.xlsx"
    send_data pkg.to_stream.read, filename: filename, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end

  # Other placeholder methods
  def evaluation_report; evaluation_data; render :evaluation_report; end
  def evaluation_result; end
  def recommendation; end
  def sow; end
  def missing_items; end
  def differences; end
  def interfaces; end

  private

  def load_subsystems
    @subsystems = Subsystem.order(:name)
  end

  def load_suppliers_with_subsystems
    return (@suppliers_with_subsystems = Supplier.none) unless params[:subsystem_id].present?

    sid = params[:subsystem_id].to_i
    tds = TableDefinition.where(subsystem_id: sid)

    ids = tds.flat_map do |td|
      model = Class.new(ActiveRecord::Base) do
        self.table_name = td.table_name
        self.inheritance_column = :_type_disabled
      end

      if model.column_names.include?('supplier_id') && model.column_names.include?('subsystem_id')
        model.where(subsystem_id: sid).pluck(:supplier_id)
      else
        []
      end
    end.uniq.compact

    @suppliers_with_subsystems = Supplier.where(id: ids)
  end

  def load_single_context
    @supplier = Supplier.find(params[:supplier_id])
    @subsystem = Subsystem.find(params[:subsystem_id])
    @table_defs = TableDefinition.where(subsystem_id: @subsystem.id).order(:position)
  end

  def load_multi_context
    @subsystem = Subsystem.find(params[:subsystem_id])
    @suppliers = Supplier.where(id: Array(params[:selected_suppliers]).map(&:to_i))
    @table_defs = TableDefinition.where(subsystem_id: @subsystem.id).order(:position)
  end

  def fetch_record(td, supplier, subsystem)
    model = Class.new(ActiveRecord::Base) do
      self.table_name = td.table_name
      self.inheritance_column = :_type_disabled
    end
    model.find_by(supplier_id: supplier.id, subsystem_id: subsystem.id)
  end

  def system_cols
    %w[id created_at updated_at supplier_id subsystem_id]
  end
end
