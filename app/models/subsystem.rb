class Subsystem < ApplicationRecord
  belongs_to :system
  has_many :subsystem_suppliers, dependent: :destroy
  has_many :fire_alarm_control_panels, dependent: :destroy
  has_many :detectors_field_devices, dependent: :destroy
  has_many :manual_pull_stations, dependent: :destroy
  has_many :door_holders, dependent: :destroy
  has_many :graphic_systems, dependent: :destroy
  has_many :notification_devices, dependent: :destroy
  has_many :product_data, class_name: 'ProductData', dependent: :destroy
  has_many :supplier_data, class_name: "SupplierData", dependent: :destroy
  has_many :suppliers, through: :subsystem_suppliers

  has_and_belongs_to_many :suppliers
end
