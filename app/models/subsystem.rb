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
  has_many :product_data, class_name: 'ProductData', dependent: :destroy
  has_many :supplier_data, class_name: 'SupplierData', dependent: :destroy
  has_many :connection_betweens, dependent: :destroy
  has_many :interface_with_other_systems, dependent: :destroy
  has_many :evacuation_systems, dependent: :destroy
  has_many :prerecorded_message_audio_modules, dependent: :destroy
  has_many :telephone_systems, dependent: :destroy
  has_many :spare_parts, dependent: :destroy
  has_many :scope_of_works, dependent: :destroy
  has_many :material_and_deliveries, dependent: :destroy
  has_many :general_commercial_data, dependent: :destroy

  # Allow nested attributes for all associations that can be updated via the submission form
  accepts_nested_attributes_for :fire_alarm_control_panels, allow_destroy: true
  accepts_nested_attributes_for :detectors_field_devices, allow_destroy: true
  accepts_nested_attributes_for :manual_pull_stations, allow_destroy: true
  accepts_nested_attributes_for :door_holders, allow_destroy: true
  accepts_nested_attributes_for :graphic_systems, allow_destroy: true
  accepts_nested_attributes_for :notification_devices, allow_destroy: true
  accepts_nested_attributes_for :isolations, allow_destroy: true
  accepts_nested_attributes_for :product_data, allow_destroy: true
  accepts_nested_attributes_for :supplier_data, allow_destroy: true
  accepts_nested_attributes_for :connection_betweens, allow_destroy: true
  accepts_nested_attributes_for :interface_with_other_systems, allow_destroy: true
  accepts_nested_attributes_for :evacuation_systems, allow_destroy: true
  accepts_nested_attributes_for :prerecorded_message_audio_modules, allow_destroy: true
  accepts_nested_attributes_for :telephone_systems, allow_destroy: true
  accepts_nested_attributes_for :spare_parts, allow_destroy: true
  accepts_nested_attributes_for :scope_of_works, allow_destroy: true
  accepts_nested_attributes_for :material_and_deliveries, allow_destroy: true
  accepts_nested_attributes_for :general_commercial_data, allow_destroy: true

  has_and_belongs_to_many :suppliers
end
