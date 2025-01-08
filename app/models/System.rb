class System < ApplicationRecord
    belongs_to :project
    has_many :subsystems, dependent: :destroy
  end
  