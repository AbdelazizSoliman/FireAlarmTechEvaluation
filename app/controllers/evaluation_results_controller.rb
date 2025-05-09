# app/controllers/evaluation_results_controller.rb
class EvaluationResultsController < ApplicationController
  before_action :load_context

  def index
    @results = EvaluationResult
                 .where(supplier: @supplier, subsystem: @subsystem)
                 .order(:table_name, :column_name)
  end

  def evaluate
    SubmissionEvaluator.new(
      supplier:  @supplier,
      subsystem: @subsystem
    ).run!

    redirect_to evaluation_results_path(
      supplier_id:   @supplier,
      subsystem_id:  @subsystem
    ), notice: "Re‐evaluated successfully."
  end

  def download
    results = EvaluationResult
                .where(supplier: @supplier, subsystem: @subsystem)
                .order(:table_name, :column_name)

    pkg = Axlsx::Package.new
    pkg.workbook.add_worksheet(name: "Results") do |sheet|
      sheet.add_row ["Supplier:", @supplier.supplier_name]
      sheet.add_row ["Subsystem:", @subsystem.name]
      sheet.add_row []
      sheet.add_row ["Attribute","Submitted","Standard","Tolerance(%)","Degree","Status"]

      results.each do |r|
        sheet.add_row [
          r.column_name,
          r.submitted_value,
          r.standard_value,
          r.tolerance,
          r.degree,
          r.status
        ]
      end
    end

    tmp = Tempfile.new(["evaluation_results", ".xlsx"])
    pkg.serialize(tmp.path)
    send_file tmp.path,
              filename:    "evaluation_results_#{@supplier.id}_#{@subsystem.id}.xlsx",
              disposition: "attachment",
              type:        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  ensure
    tmp.close! rescue nil
  end

  private

  def load_context
    @supplier  = Supplier.find(params[:supplier_id])
    @subsystem = Subsystem.find(params[:subsystem_id])
  end
end
