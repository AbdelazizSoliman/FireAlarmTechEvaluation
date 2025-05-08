# app/services/submission_evaluator.rb
class SubmissionEvaluator
  def initialize(supplier:, subsystem:)
    @supplier   = supplier
    @subsystem  = subsystem
    @criteria   = ColumnMetadata
                    .where(table_name: TableDefinition.where(subsystem_id: subsystem.id).pluck(:table_name))
                    .index_by(&:id)
  end

  # Returns a hash of { column_metadata_id => { degree, status } }
  def run
    results = {}

    @criteria.each do |col_meta_id, crit|
      raw = fetch_supplier_value(crit)
      next if raw.nil?

      score = evaluate_numeric_or_choices(raw, crit)
      status = score >= 1.0 ? "pass" : "fail"

      # Persist into evaluation_results
      er = EvaluationResult.find_or_initialize_by(
        supplier:        @supplier,
        column_metadata: crit
      )
      er.degree = score
      er.status = status
      er.save!

      results[col_meta_id] = { degree: score, status: status }
    end

    results
  end

  private

  def fetch_supplier_value(crit)
    # spin up the AR model for crit.table_name and get the column crit.column_name
    model = Class.new(ActiveRecord::Base) do
      self.table_name        = crit.table_name
      self.inheritance_column = :_type_disabled
    end
    rec = model.find_by(supplier_id: @supplier.id, subsystem_id: @subsystem.id)
    rec&.public_send(crit.column_name)
  end

  def evaluate_numeric_or_choices(raw, crit)
    std   = crit.standard_value.to_f
    tol   = crit.tolerance.to_f / 100.0
    min   = std * (1 - tol)
    max   = std * (1 + tol)
    val   = raw.to_f

    # 1.0 if within [min,max], otherwise 0.0
    (val >= min && val <= max) ? 1.0 : 0.0
  end
end
