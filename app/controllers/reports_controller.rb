# app/controllers/reports_controller.rb
class ReportsController < ApplicationController
  # Only for the Tech/Apple-to-Apple _forms_
  before_action :load_subsystems,               only: [:evaluation_tech_report, :apple_to_apple_comparison]
  before_action :load_suppliers_with_subsystems, only: [:evaluation_tech_report, :apple_to_apple_comparison]

  # Single‐supplier report (HTML & Excel)
  before_action :load_single_context, only: [:evaluation_data, :generate_evaluation_report]

  # Multi‐supplier comparison (HTML & Excel)
  before_action :load_multi_context,  only: [:show_comparison_report, :generate_comparison_report]

  # GET /reports
  def index
    # your dashboard / links
  end

  # — Tech Form —
  # GET /reports/evaluation_tech_report
  def evaluation_tech_report; end

  # — Single‐supplier HTML —
  # GET /reports/evaluation_data?supplier_id=…&subsystem_id=…
  def evaluation_data
    @data_by_table = @table_defs.each_with_object({}) do |td, h|
      rec   = fetch_record(td, @supplier, @subsystem)
      attrs = rec&.attributes&.except(*system_cols) || {}
      h[td.table_name] = attrs
    end
  end

  # — Single‐supplier Excel —
  # GET /reports/generate_evaluation_report?supplier_id=…&subsystem_id=…
  def generate_evaluation_report
    p  = Axlsx::Package.new
    wb = p.workbook

    wb.add_worksheet(name: 'Evaluation Data') do |sheet|
      sheet.add_row ['Section', 'Attribute', 'Value'], b: true

      @table_defs.each do |td|
        sheet.add_row [td.table_name.titleize, nil, nil], b: true
        rec   = fetch_record(td, @supplier, @subsystem)
        attrs = rec&.attributes&.except(*system_cols) || {}

        attrs.each do |col, val|
          disp = val.is_a?(Array) ? val.join(', ') : val.to_s
          sheet.add_row [nil, col.humanize, disp]
        end

        sheet.add_row []
      end
    end

    fn = "Evaluation_#{@supplier.supplier_name}_#{@subsystem.name}.xlsx"
    send_data p.to_stream.read,
              filename: fn,
              type:    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end

  # — Apple‐to‐Apple Form —
  # GET /reports/apple_to_apple_comparison
  def apple_to_apple_comparison; end

  # — Multi‐supplier HTML —
  # GET /reports/show_comparison_report?subsystem_id=…&selected_suppliers[]=…
  def show_comparison_report
    @comparison_data = @table_defs.each_with_object({}) do |td, out|
      out[td.table_name] = @suppliers.map do |sup|
        rec   = fetch_record(td, sup, @subsystem)
        attrs = rec&.attributes&.except(*system_cols) || {}
        [sup.supplier_name, attrs]
      end.to_h
    end
  end

  # — Multi‐supplier Excel —
  # GET /reports/generate_comparison_report?subsystem_id=…&selected_suppliers[]=…
  def generate_comparison_report
    p  = Axlsx::Package.new
    wb = p.workbook

    wb.add_worksheet(name: 'Comparison') do |sheet|
      # group definitions by parent_table (nil = top-level parents)
      grouped = @table_defs.group_by(&:parent_table)
      parents = grouped[nil] || []

      parents.each do |parent_td|
        # 1) Parent heading row, bold
        sheet.add_row [parent_td.table_name.titleize] + [''] * @suppliers.size,
                      b: true

        children = grouped[parent_td.table_name] || []

        # 2) If it has subtables, iterate them…
        if children.any?
          children.each do |ctd|
            # Sub-table heading
            sheet.add_row [ctd.table_name.titleize] + [''] * @suppliers.size,
                          b: true

            # Gather each supplier’s record for this sub-table
            hashes = @suppliers.map do |sup|
              rec = fetch_record(ctd, sup, @subsystem)
              rec ? rec.attributes.except(*system_cols) : {}
            end

            # All attribute keys
            all_keys = hashes.flat_map(&:keys).uniq.sort

            # One row per attribute
            all_keys.each do |col|
              row = [col.humanize]
              hashes.each do |h|
                v = h[col]
                row << (v.is_a?(Array) ? v.join(', ') : v.to_s)
              end
              sheet.add_row row
            end

            # Spacer
            sheet.add_row []
          end

        # 3) Otherwise treat the parent itself as the table…
        else
          hashes = @suppliers.map do |sup|
            rec = fetch_record(parent_td, sup, @subsystem)
            rec ? rec.attributes.except(*system_cols) : {}
          end

          all_keys = hashes.flat_map(&:keys).uniq.sort

          all_keys.each do |col|
            row = [col.humanize]
            hashes.each do |h|
              v = h[col]
              row << (v.is_a?(Array) ? v.join(', ') : v.to_s)
            end
            sheet.add_row row
          end

          sheet.add_row []
        end
      end
    end

    filename = "Comparison_#{@subsystem.name.parameterize}.xlsx"
    send_data p.to_stream.read,
              filename: filename,
              type:    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end

  # (other stubs…)
  def evaluation_report;         evaluation_data; render :evaluation_report; end
  def evaluation_result;         end
  def recommendation;            end
  def sow;                       end
  def missing_items;             end
  def differences;               end
  def interfaces;                end

  private

  # — Form dropdowns — load every subsystem
  def load_subsystems
    @subsystems = Subsystem.order(:name)
  end

  # — For both forms — load suppliers who have at least one record in **any** table for the chosen subsystem
  def load_suppliers_with_subsystems
    return (@suppliers_with_subsystems = Supplier.none) unless params[:subsystem_id].present?

    sid = params[:subsystem_id].to_i
    tds = TableDefinition.where(subsystem_id: sid)

    ids = tds.flat_map do |td|
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

    @suppliers_with_subsystems = Supplier.where(id: ids)
  end

  # — Single‐supplier context loader —
  def load_single_context
    @supplier   = Supplier.find(params[:supplier_id])
    @subsystem  = Subsystem.find(params[:subsystem_id])
    @table_defs = TableDefinition.where(subsystem_id: @subsystem.id).order(:position)
  end

  # — Multi‐supplier context loader —
  def load_multi_context
    @subsystem  = Subsystem.find(params[:subsystem_id])
    @suppliers  = Supplier.where(id: Array(params[:selected_suppliers]).map(&:to_i))
    @table_defs = TableDefinition.where(subsystem_id: @subsystem.id).order(:position)
  end

  # Helper to spin up an AR model and fetch a record
  def fetch_record(td, supplier, subsystem)
    model = Class.new(ActiveRecord::Base) do
      self.table_name        = td.table_name
      self.inheritance_column = :_type_disabled
    end
    model.find_by(supplier_id: supplier.id, subsystem_id: subsystem.id)
  end

  # Columns to strip out of the reports
  def system_cols
    %w[id created_at updated_at supplier_id subsystem_id]
  end
end
