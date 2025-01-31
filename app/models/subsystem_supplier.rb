class SubsystemSupplier < ApplicationRecord
  belongs_to :subsystem
  belongs_to :supplier

  validates :approved, inclusion: { in: [true, false] }
  after_create :create_notification

  private
end
