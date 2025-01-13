class ProjectScope < ApplicationRecord
    belongs_to :project
  has_many :systems, dependent: :destroy
  has_many :subsystems, through: :systems
  end