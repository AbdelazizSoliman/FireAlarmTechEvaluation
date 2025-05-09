# app/services/submission_evaluator.rb
class SubmissionEvaluator
  def initialize(supplier:, subsystem:)
    @supplier  = supplier
    @subsystem = subsystem
  end

  # wipes old results for this pair, then re‐evaluates
  def run!
    EvaluationResult.where(supplier: @supplier, subsystem: @subsystem).delete_all

    TableDefinition
      .where(subsystem: @subsystem)
      .pluck(:table_name)
      .each { |tbl| evaluate_table(tbl) }
  end

  private

  def evaluate_table(table_name)
    model = Class.new(ActiveRecord::Base) do
      self.table_name         = table_name
      self.inheritance_column = :_type_disabled
    end

    row = model.find_by(
      supplier_id:  @supplier.id,
      subsystem_id: @subsystem.id
    )
    return unless row

    ColumnMetadata
      .where(table_name: table_name)
      .where.not(standard_value: nil)
      .find_each do |meta|

      subm = row.send(meta.column_name)&.to_f
      std  = meta.standard_value.to_f
      tol  = meta.tolerance.to_f

      min_ok = std * (1 - tol / 100.0)

      if subm >= std
        degree = 1.0; status = "pass"
      elsif subm >= min_ok
        degree = 0.5; status = "pass_within_tolerance"
      else
        degree = 0.0; status = "fail"
      end

      EvaluationResult.create!(
        supplier:        @supplier,
        subsystem:       @subsystem,
        table_name:      table_name,
        column_name:     meta.column_name,
        submitted_value: subm,
        standard_value:  std,
        tolerance:       tol,
        degree:          degree,
        status:          status
      )
    end
  end
end
