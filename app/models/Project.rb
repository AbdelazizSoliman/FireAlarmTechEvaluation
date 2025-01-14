class Project < ApplicationRecord
  has_many :project_scopes, dependent: :destroy
  has_many :systems, through: :project_scopes
  has_many :subsystems, through: :systems
end
