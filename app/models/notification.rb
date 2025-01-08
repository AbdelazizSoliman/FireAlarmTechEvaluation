class Notification < ApplicationRecord
  belongs_to :notifiable, polymorphic: true
  validates :title, :body, presence: true
  after_initialize :set_defaults, if: :new_record?

  private

  def set_defaults
    self.read ||= false
    self.status ||= 'pending'
  end
end
