class ComparisonsController < ApplicationController
  def index
    @supplier_categorys = Supplier.distinct.pluck(:supplier_category)
    # Fetch suppliers with subsystems that have evaluations submitted
    @suppliers = Supplier.includes(subsystems: %i[detectors_field_devices fire_alarm_control_panels product_data
                                                  notification_devices])
      .where.not(subsystems: { detectors_field_devices: nil }) # Filter subsystems with evaluations
  end

  def generate
    supplier_category = params[:supplier_category]

    @suppliers = if supplier_category.present?
                   Supplier.joins(:subsystems).where(supplier_category: supplier_category)
                     .where.not(subsystems: { detectors_field_devices: nil }) # Filter subsystems with evaluations
                 else
                   Supplier.joins(:subsystems).where.not(subsystems: { detectors_field_devices: nil })
                 end

    # Prepare data for the comparison (e.g., metrics, performance, etc.)
    # This can be added based on your requirements
  end
end
