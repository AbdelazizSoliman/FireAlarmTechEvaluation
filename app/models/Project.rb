class Project < ApplicationRecord
  has_one :product, dependent: :destroy
  has_one :fire_alarm_control_panel, dependent: :destroy
  has_one :graphic_system, dependent: :destroy

  accepts_nested_attributes_for :product
  accepts_nested_attributes_for :fire_alarm_control_panel
  accepts_nested_attributes_for :graphic_system
end
