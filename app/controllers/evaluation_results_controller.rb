class EvaluationResultsController < ApplicationController
  def index
    @supplier  = Supplier.find(params[:supplier_id])
    @subsystem = Subsystem.find(params[:subsystem_id])
    @results   = EvaluationResult
                   .where(supplier: @supplier, subsystem: @subsystem)
                   .order(:table_name, :column_name)
  end

  # POST /evaluation_results/evaluate
  def evaluate
    supplier  = Supplier.find(params[:supplier_id])
    subsystem = Subsystem.find(params[:subsystem_id])

    # Recompute all attributes for this supplier+subsystem
    # (you might clear out old ones first if you like)
    TableDefinition
      .where(subsystem_id: subsystem.id)
      .pluck(:table_name)
      .each do |table_name|
        model = table_name.classify.constantize
        record = model.find_by(supplier_id: supplier.id, subsystem_id: subsystem.id)
        next unless record

        record.attributes.each do |column, submitted|
          next if %w[id supplier_id subsystem_id created_at updated_at].include?(column)

          meta = ColumnMetadata.find_by(
            table_name:  table_name,
            column_name: column
          )

          next unless meta&.standard_value && meta.tolerance

          standard = meta.standard_value
          tol      = meta.tolerance
          min_ok   = standard - (standard * tol / 100.0)

          degree, status =
            if submitted.to_f >= standard
              [1.0, "pass"]
            elsif submitted.to_f >= min_ok
              [0.5, "pass"]
            else
              [0.0, "fail"]
            end

          EvaluationResult
            .find_or_initialize_by(
              table_name:  table_name,
              column_name: column,
              supplier:    supplier,
              subsystem:   subsystem
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
      supplier_id:   supplier.id,
      subsystem_id:  subsystem.id
    ), notice: "Re-evaluation complete!"
  end

  # GET /evaluation_results/download
  def download
    @supplier  = Supplier.find(params[:supplier_id])
    @subsystem = Subsystem.find(params[:subsystem_id])
    @results   = EvaluationResult
                   .where(supplier: @supplier, subsystem: @subsystem)
                   .order(:table_name, :column_name)

    p = Axlsx::Package.new
    p.workbook.add_worksheet(name: "Eval #{ @supplier.name } / #{ @subsystem.name }") do |sheet|
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

    tmp = Tempfile.new(["evaluation", ".xlsx"])
    p.serialize(tmp.path)
    send_file tmp.path,
              filename:     "evaluation_#{ @supplier.name }_#{ @subsystem.name }.xlsx",
              type:         "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end
end
