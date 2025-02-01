class Subsystem < ApplicationRecord
  belongs_to :system
  has_many :subsystem_suppliers, dependent: :destroy
  has_many :fire_alarm_control_panels, dependent: :destroy
  has_many :detectors_field_devices, dependent: :destroy
  has_many :manual_pull_stations, dependent: :destroy
  has_many :door_holders, dependent: :destroy
  has_many :graphic_systems, dependent: :destroy
  has_many :notification_devices, dependent: :destroy
  has_many :isolations, dependent: :destroy
  has_many :product_data, class_name: "ProductData", dependent: :destroy
  has_many :supplier_data, class_name: "SupplierData", dependent: :destroy
  has_many :suppliers, through: :subsystem_suppliers
  has_many :connection_betweens, dependent: :destroy
  has_many :interface_with_other_systems, dependent: :destroy
  has_many :evacuation_systems, dependent: :destroy
  has_many :prerecorded_message_audio_modules, dependent: :destroy
  has_many :telephone_systems, dependent: :destroy
  has_many :spare_parts, dependent: :destroy
  has_many :scope_of_works, dependent: :destroy
  has_many :material_and_deliveries, dependent: :destroy
  has_many :general_commercial_data, dependent: :destroy

  has_and_belongs_to_many :suppliers
end
