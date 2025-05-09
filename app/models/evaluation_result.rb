class EvaluationResult < ApplicationRecord
  belongs_to :supplier
  belongs_to :subsystem
  belongs_to :column_metadata

  validates :degree, numericality: true, allow_nil: true
  validates :status, inclusion: { in: %w[pass fail] }, allow_nil: true
end
