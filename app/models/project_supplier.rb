class ProjectSupplier < ApplicationRecord
  belongs_to :project
  belongs_to :supplier

  validates :approved, inclusion: { in: [true, false] }
end
