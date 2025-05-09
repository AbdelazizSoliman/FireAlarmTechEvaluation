# app/controllers/evaluation_results_controller.rb
class EvaluationResultsController < ApplicationController
  def index
    @supplier  = Supplier.find(params[:supplier_id])
    @subsystem = Subsystem.find(params[:subsystem_id])
    @results   = EvaluationResult
                   .where(supplier_id:  @supplier.id,
                          subsystem_id: @subsystem.id)
                   .order(:table_name, :column_name)
  end

  # POST /evaluation_results/evaluate
  def evaluate
    supplier  = Supplier.find(params[:supplier_id])
    subsystem = Subsystem.find(params[:subsystem_id])

    # Recompute (or create) one EvaluationResult per column
    TableDefinition
      .where(subsystem_id: subsystem.id)
      .pluck(:table_name)
      .each do |table_name|
        # Build a quick inline model for that dynamic table
        model = Class.new(ActiveRecord::Base) do
          self.table_name        = table_name
          self.inheritance_column = :_type_disabled
        end

        record = model.find_by(
          supplier_id:  supplier.id,
          subsystem_id: subsystem.id
        )
        next unless record

        record.attributes.each do |column, submitted|
          # skip the AR bookkeeping columns
          next if %w[id supplier_id subsystem_id created_at updated_at].include?(column)

          # only evaluate columns with standards
          meta = ColumnMetadata.find_by(
            table_name:  table_name,
            column_name: column
          )
          next unless meta&.standard_value && meta.tolerance

          standard = meta.standard_value.to_f
          tol      = meta.tolerance.to_f
          min_ok   = standard - (standard * tol / 100.0)

          degree, status =
            if submitted.to_f >= standard
              [1.0, 'pass']
            elsif submitted.to_f >= min_ok
              [0.5, 'pass']
            else
              [0.0, 'fail']
            end

          # find or init the EvaluationResult row
          EvaluationResult
            .find_or_initialize_by(
              supplier_id:  supplier.id,
              subsystem_id: subsystem.id,
              table_name:   table_name,
              column_name:  column
            )
            .update!(
              submitted_value: submitted,
              standard_value:  standard,
              tolerance:       tol,
              degree:          degree,
              status:          status
            )
        end
      end

    redirect_to evaluation_results_path(
      supplier_id:  supplier.id,
      subsystem_id: subsystem.id
    ), notice: 'Re-evaluation complete!'
  end

  # GET /evaluation_results/download
  def download
    @supplier  = Supplier.find(params[:supplier_id])
    @subsystem = Subsystem.find(params[:subsystem_id])
    @results   = EvaluationResult
                   .where(supplier_id:  @supplier.id,
                          subsystem_id: @subsystem.id)
                   .order(:table_name, :column_name)

    package = Axlsx::Package.new
    raw_name = "Eval #{@supplier.supplier_name} - #{@subsystem.name}"
    safe_name = raw_name
                  .gsub(/[\\\/\?\*\[\]]/, '-')   # replace invalid chars with hyphens
                  .slice(0, 31)                  # Excel limits sheet names to 31 characters

    package.workbook.add_worksheet(name: safe_name) do |sheet|
      sheet.add_row [
        "Attribute",
        "Submitted Value",
        "Standard Value",
        "Tolerance (%)",
        "Degree",
        "Status"
      ]
      @results.each do |r|
        sheet.add_row [
          "#{r.table_name}.#{r.column_name}",
          r.submitted_value,
          r.standard_value,
          r.tolerance,
          r.degree,
          r.status
        ]
      end
    end
    tmp = Tempfile.new(['evaluation', '.xlsx'])
    package.serialize(tmp.path)

    send_file tmp.path,
      filename: "evaluation_#{@supplier.supplier_name}_#{@subsystem.name}.xlsx",
      type:     'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end
end
