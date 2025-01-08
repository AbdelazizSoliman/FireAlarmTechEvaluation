class Project < ApplicationRecord
  has_many :light_current_systems, dependent: :destroy
end
