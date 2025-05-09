class EvaluationResultsController < ApplicationController
  def index
    @supplier  = Supplier.find(params[:supplier_id])
    @subsystem = Subsystem.find(params[:subsystem_id])
    @results    = EvaluationResult
    .where(supplier_id:  @supplier.id,
           subsystem_id: @subsystem.id)
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
  each do |table_name|
    model  = Class.new(ActiveRecord::Base) { … }
    record = model.find_by(…)
    next unless record
  
    record.attributes.each do |column, submitted|
      …
      meta = ColumnMetadata.find_by(…)
      next unless meta&.standard_value && meta.tolerance
  
      degree, status = … # your logic
  
      # ⚡️ Associate the metadata here:
      er = EvaluationResult.find_or_initialize_by(
        supplier_id:          supplier.id,
        subsystem_id:         subsystem.id,
        table_name:           table_name,
        column_name:          column,
        column_metadata_id:   meta.id
      )
  
      er.update!(
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
