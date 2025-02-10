class ComparisonsController < ApplicationController
  def index
    @registration_types = Supplier.distinct.pluck(:registration_type)
    # Fetch suppliers with subsystems that have evaluations submitted
    @suppliers = Supplier.includes(subsystems: %i[detectors_field_devices fire_alarm_control_panels product_data
                                                  notification_devices])
      .where.not(subsystems: { detectors_field_devices: nil }) # Filter subsystems with evaluations
  end

  def generate
    registration_type = params[:registration_type]

    @suppliers = if registration_type.present?
                   Supplier.joins(:subsystems).where(registration_type: registration_type)
                     .where.not(subsystems: { detectors_field_devices: nil }) # Filter subsystems with evaluations
                 else
                   Supplier.joins(:subsystems).where.not(subsystems: { detectors_field_devices: nil })
                 end

    # Prepare data for the comparison (e.g., metrics, performance, etc.)
    # This can be added based on your requirements
  end
end
