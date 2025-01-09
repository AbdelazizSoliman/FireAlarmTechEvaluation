class Subsystem < ApplicationRecord
  belongs_to :system
  has_many :subsystem_suppliers, dependent: :destroy
  has_many :fire_alarm_control_panels, dependent: :destroy

end
