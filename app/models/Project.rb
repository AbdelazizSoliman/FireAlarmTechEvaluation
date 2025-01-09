class Project < ApplicationRecord
  has_many :systems, dependent: :destroy
end
