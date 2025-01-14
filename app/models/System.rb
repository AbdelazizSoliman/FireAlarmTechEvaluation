class System < ApplicationRecord
  belongs_to :project
  belongs_to :project_scope

  has_many :subsystems, dependent: :destroy

  validates :project, presence: true
  validates :project_scope, presence: true
  
  end
  