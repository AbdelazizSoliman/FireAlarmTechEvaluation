class ProjectScope < ApplicationRecord
    belongs_to :project
    has_many :systems
  end