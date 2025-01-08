class Supplier < ApplicationRecord
  STATUSES = %w[pending approved rejected]
  has_secure_password

  validates :password, presence: true, length: { minimum: 6 }, confirmation: true, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  validates :status, inclusion: { in: STATUSES }
  after_initialize :set_default_status, if: :new_record?

  validates :supplier_name, :supplier_category, :total_years_in_saudi_market, :phone, :supplier_email, presence: true
  validates :supplier_email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'must be a valid email address' }

  has_many :subsystem_suppliers, dependent: :destroy
  has_many :subsystems, through: :subsystem_suppliers

  private

  # Skip password validation when updating non-password fields
  def password_required?
    new_record? || password.present? || password_confirmation.present?
  end

  def set_default_status
    self.status ||= 'pending'
  end
end
