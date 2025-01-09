class SubsystemSupplier < ApplicationRecord
  belongs_to :subsystem
  belongs_to :supplier

  after_create :create_notification

  private

  def create_notification
    Notification.create!(
      title: "New Project Assigned",
      body: "Great news, you were assigned a new project: #{subsystem.name}. Please check your projects.",
      notifiable: self.supplier,
      read: false,
      status: "unread"
    )
  end
end
