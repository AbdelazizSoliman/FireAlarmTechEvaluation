class Supplier < ApplicationRecord
  REGISTRATION_TYPES = %w[partnership evaluation].freeze
  EVALUATION_TYPES = %w[TechnicalOnly TechnicalAndEvaluation].freeze
  # MEMBERSHIP_TYPES = %w[projects systems].freeze
  STATUSES = %w[pending approved rejected]
  has_secure_password

  validates :receive_evaluation_report, inclusion: { in: [true, false] }, if: :status_approved?

  validates :password, presence: true, length: { minimum: 6 }, confirmation: true, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  validates :status, inclusion: { in: STATUSES }
  after_initialize :set_default_status, if: :new_record?

  validates :supplier_name, :supplier_category, :total_years_in_saudi_market, :phone, :supplier_email, presence: true
  validates :supplier_email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  validates :registration_type, inclusion: { in: ["Manufacturer / Vendor", "System Integrator", "Sub Contractor", "Supplier"] }
  validates :purpose, inclusion: { in: ["Participant", "Already Quoted & Need Evaluation"], allow_blank: true }
  validates :evaluation_type, inclusion: { in: ["TechnicalOnly", "Technical&Evaluation"], allow_blank: true }

  has_many :subsystem_suppliers, dependent: :destroy
  has_many :subsystems, through: :subsystem_suppliers

  has_and_belongs_to_many :projects, join_table: :projects_suppliers
  has_and_belongs_to_many :project_scopes, join_table: :project_scopes_suppliers
  has_and_belongs_to_many :systems, join_table: :systems_suppliers
  has_and_belongs_to_many :subsystems, join_table: :subsystems_suppliers
  has_many :notifications, as: :notifiable, dependent: :destroy

  def allowable_subsystems
    subsystems.where(approved: true)
  end

  def allowable_projects
    projects.where(approved: true)
  end

  # Update approval status
  def approve_subsystems(subsystem_ids)
    subsystems_suppliers.where(subsystem_id: subsystem_ids).update_all(approved: true)
  end

  def disapprove_subsystems(subsystem_ids)
    subsystems_suppliers.where(subsystem_id: subsystem_ids).update_all(approved: false)
  end

  def approve_projects(project_ids)
    projects_suppliers.where(project_id: project_ids).update_all(approved: true)
  end

  def disapprove_projects(project_ids)
    projects_suppliers.where(project_id: project_ids).update_all(approved: false)
  end

  # Fetch approved subsystems and projects
  def approved_subsystems
    subsystems_suppliers.where(approved: true).map(&:subsystem)
  end

  def approved_projects
    projects_suppliers.where(approved: true).map(&:project)
  end

  private

  def approve_associations(params)
    self.projects.where(id: params[:project_ids]).update_all(approved: true)
    self.project_scopes.where(id: params[:project_scope_ids]).update_all(approved: true)
    self.systems.where(id: params[:system_ids]).update_all(approved: true)
    self.subsystems.where(id: params[:subsystem_ids]).update_all(approved: true)
  end
  

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
    self.status ||= "pending"
  end

  def status_approved?
    status == "approved"
  end
end
