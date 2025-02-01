class System < ApplicationRecord
  belongs_to :project_scope
    has_many :subsystems, dependent: :destroy
    has_and_belongs_to_many :suppliers
  end
  