class System < ApplicationRecord
  belongs_to :project_scope
    has_many :subsystems, dependent: :destroy
  end
  