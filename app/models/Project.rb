class Project < ApplicationRecord
  has_many :systems, dependent: :destroy
  has_one :fire_alarm_control_panel
accepts_nested_attributes_for :fire_alarm_control_panel
end
