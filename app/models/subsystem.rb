class Subsystem < ApplicationRecord
  belongs_to :system
  has_many :suppliers, through: :subsystem_suppliers


end
