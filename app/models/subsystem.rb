class Subsystem < ApplicationRecord
  belongs_to :system
  has_many :subsystem_suppliers, dependent: :destroy
  has_many :fire_alarm_control_panels, dependent: :destroy
  has_many :suppliers, through: :subsystem_suppliers

  has_and_belongs_to_many :suppliers

end
