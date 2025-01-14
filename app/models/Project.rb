class Project < ApplicationRecord
  # has_many :systems, dependent: :destroy
  has_many :project_scopes
  has_and_belongs_to_many :suppliers
#   has_one :fire_alarm_control_panel
# accepts_nested_attributes_for :fire_alarm_control_panel
end
