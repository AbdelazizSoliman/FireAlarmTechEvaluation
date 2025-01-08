class Subsystem < ApplicationRecord
  belongs_to :system
  has_many :subsystem_suppliers, dependent: :destroy
  has_many :suppliers, through: :subsystem_suppliers
  has_one :fire_alarm_system, dependent: :destroy
end
