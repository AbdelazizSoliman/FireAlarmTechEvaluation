class Supplier < ApplicationRecord
  STATUSES = %w[pending approved rejected]
  has_secure_password

  validates :membership_type, presence: true, if: :status_approved?
  validates :receive_evaluation_report, inclusion: { in: [true, false] }, if: :status_approved?

  validates :password, presence: true, length: { minimum: 6 }, confirmation: true, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  validates :status, inclusion: { in: STATUSES }
  after_initialize :set_default_status, if: :new_record?

  validates :supplier_name, :supplier_category, :total_years_in_saudi_market, :phone, :supplier_email, presence: true
  validates :supplier_email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'must be a valid email address' }

  has_many :subsystem_suppliers, dependent: :destroy
  has_many :subsystems, through: :subsystem_suppliers

  has_and_belongs_to_many :projects
  has_and_belongs_to_many :subsystems

 # Callbacks
 before_update :clear_old_associations, if: :membership_type_changed?

  private

  def clear_old_associations
    if membership_type_was == "gold"
      projects.clear
    elsif membership_type_was == "silver"
      subsystems.clear
    end
  end

  # Skip password validation when updating non-password fields
  def password_required?
    new_record? || password.present? || password_confirmation.present?
  end

  def set_default_status
    self.status ||= 'pending'
  end
  def status_approved?
    status == "approved"
  end
end
