class SubsystemSupplier < ApplicationRecord
  belongs_to :subsystem
  belongs_to :supplier

  after_create :create_notification

  private

end
