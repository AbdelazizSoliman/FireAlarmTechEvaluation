class NotificationsController < ApplicationController
  before_action :set_notification, only: [:manage_membership, :approve_supplier, :reject_supplier]
  before_action :set_supplier, only: [:manage_membership, :approve_supplier, :reject_supplier]

  def index
    @notifications = Notification.all
    # @notifications = Notification.where(read: false).order(created_at: :desc)
    # render json: @notifications
  end

  def manage_membership
    @supplier = Supplier.find(params[:supplier_id])
    @projects = Project.all
    @subsystems = Subsystem.all
  end

  def approve_supplier
    Rails.logger.info "Params received: #{params.inspect}"
  
    # Ensure supplier_id is present
    if params[:supplier_id].blank?
      redirect_to manage_membership_notification_path(@notification), alert: "Supplier ID is missing."
      return
    end
  
    # Find the supplier
    @supplier = Supplier.find(params[:supplier_id])
  
    if params[:membership_type].blank? || params[:receive_evaluation_report].blank?
      redirect_to manage_membership_notification_path(@notification, supplier_id: @supplier.id), alert: "Please select all required fields."
      return
    end
  
    ActiveRecord::Base.transaction do
      # Update supplier attributes
      @supplier.update!(
        membership_type: params[:membership_type],
        receive_evaluation_report: params[:receive_evaluation_report] == "true",
        status: "approved"
      )
  
      # Assign projects or subsystems based on membership type
      if params[:membership_type] == "projects"
        selected_projects = params[:project_ids] || []
        @supplier.projects = Project.where(id: selected_projects)
      elsif params[:membership_type] == "systems"
        selected_subsystems = params[:subsystem_ids] || []
        @supplier.subsystems = Subsystem.where(id: selected_subsystems)
      end
  
      # Resolve the notification
      @notification.update!(status: "resolved")
    end
  
    redirect_to suppliers_path, notice: "#{@supplier.supplier_name} has been approved with #{params[:membership_type].capitalize} membership."
  rescue => e
    Rails.logger.error "Error in approve_supplier: #{e.message}"
    redirect_to manage_membership_notification_path(@notification, supplier_id: @supplier.id), alert: "Error: #{e.message}"
  end

  def reject_supplier
    ActiveRecord::Base.transaction do
      @supplier.update!(status: "rejected")
      @notification.update!(read: true, status: "resolved")
    end
  
    redirect_to notifications_path, notice: "#{@supplier.supplier_name} has been rejected."
  rescue => e
    redirect_to notifications_path, alert: "Error: #{e.message}"
  end
  

  def show
    @notification = Notification.find(params[:id])

    case request.format.symbol
    when :html
      handle_html_request
    when :pdf
      handle_pdf_request
    when :xlsx
      handle_xlsx_request
    else
      redirect_to notifications_path, alert: "Unsupported format."
    end
  end

  private

  def handle_html_request
    case @notification.notification_type
    when "registration"
      redirect_to manage_membership_notification_path(@notification)
    when "evaluation"
      if @notification.notifiable.is_a?(Subsystem)
        assign_subsystem_data
      else
        redirect_to notifications_path, alert: "Invalid notifiable type for evaluation."
      end
    else
      redirect_to notifications_path, alert: "Unknown notification type."
    end
  end

  def handle_pdf_request
    if @notification.notifiable.is_a?(Subsystem)
      assign_subsystem_data

      pdf = Prawn::Document.new
      pdf.text "Evaluation Report", size: 18, style: :bold
      pdf.move_down 20

      # Supplier Data
      add_pdf_section(pdf, "Supplier Data", @supplier_data)

      # Product Data
      add_pdf_section(pdf, "Product Data", @product_data)

      # Fire Alarm Control Panel Data
      add_pdf_section(pdf, "Fire Alarm Control Panel", @fire_alarm_control_panel)

      # Graphic System Data
      add_pdf_section(pdf, "Graphic Systems", @graphic_system)

      # Detectors Field Devices
      add_pdf_detectors(pdf, @detectors_field_device)

      # Manual Pull Station Data
      add_pdf_section(pdf, "Manual Pull Station", @manual_pull_station)

      # Door Holders
      add_pdf_door_holders(pdf, @door_holder)

       # Notification Devices (NEW)
       add_pdf_notification_devices(pdf, @notification_devices)

      send_data pdf.render,
                filename: "evaluation_report_#{@notification.id}.pdf",
                type: "application/pdf",
                disposition: "inline"
    else
      redirect_to notifications_path, alert: "Invalid notifiable type for evaluation."
    end
  end

  def handle_xlsx_request
    if @notification.notifiable.is_a?(Subsystem)
      assign_subsystem_data

      render xlsx: "show", template: "notifications/show_excel", filename: "evaluation_report.xlsx"
    else
      redirect_to notifications_path, alert: "Invalid notifiable type for evaluation."
    end
  end

  def assign_subsystem_data
    @subsystem = @notification.notifiable
    @supplier_data = @subsystem.supplier_data.first
    @product_data = @subsystem.product_data.first
    @fire_alarm_control_panel = @subsystem.fire_alarm_control_panels.first
    @graphic_system = @subsystem.graphic_systems.first
    @detectors_field_device = @subsystem.detectors_field_devices.first
    @manual_pull_station = @subsystem.manual_pull_stations.first
    @door_holder = @subsystem.door_holders.first
    @notification_devices = @subsystem.notification_devices.first
    Rails.logger.debug "Door Holder: #{@door_holder.inspect}"
  end
  

  def add_pdf_section(pdf, section_title, data)
    if data
      pdf.text section_title, size: 16, style: :bold
      pdf.move_down 10
      data.attributes.each do |key, value|
        pdf.text "#{key.humanize}: #{value}"
      end
      pdf.move_down 20
    else
      pdf.text "#{section_title} data not available.", size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_detectors(pdf, detectors)
    if detectors
      pdf.text "Detectors Field Devices", size: 16, style: :bold
      pdf.move_down 10
      detectors.attributes.each do |key, value|
        next unless key.ends_with?('_value')

        detector_type = key.sub('_value', '').humanize
        pdf.text "Type: #{detector_type}"
        pdf.text "Value: #{value}"
        pdf.text "Unit Rate: #{detectors["#{key.sub('_value', '_unit_rate')}"]}"
        pdf.text "Amount: #{detectors["#{key.sub('_value', '_amount')}"]}"
        pdf.text "Notes: #{detectors["#{key.sub('_value', '_notes')}"]}"
        pdf.move_down 10
      end
    else
      pdf.text "No Detectors Field Devices data available.", size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_door_holders(pdf, door_holders)
    if door_holders
      pdf.text "Door Holders", size: 16, style: :bold
      pdf.move_down 10
      # Explicitly map the attributes
      [
        { type: 'total_no_of_devices', label: 'Total Number of Devices' },
        { type: 'total_no_of_relays', label: 'Total Number of Relays' }
      ].each do |attribute|
        type_key = attribute[:type]
        pdf.text "Type: #{attribute[:label]}"
        pdf.text "Value: #{door_holders[type_key]}"
        pdf.text "Unit Rate: #{door_holders["#{type_key}_unit_rate"]}"
        pdf.text "Amount: #{door_holders["#{type_key}_amount"]}"
        pdf.text "Notes: #{door_holders["#{type_key}_notes"]}"
        pdf.move_down 10
      end
    else
      pdf.text "No Door Holders data available.", size: 14, style: :italic
      pdf.move_down 10
    end
  end
  
  def add_pdf_notification_devices(pdf, notification_devices)
    if notification_devices
      pdf.text "Notification Devices", size: 16, style: :bold
      pdf.move_down 10
  
      # Build a 2-column table with headers
      data = []
      data << ["Attribute", "Value"]
  
      data << ["Notification Addressing", notification_devices.notification_addressing]
      data << ["Fire Alarm Strobe", notification_devices.fire_alarm_strobe]
      data << ["Fire Alarm Strobe (WP)", notification_devices.fire_alarm_strobe_wp]
      data << ["Fire Alarm Horn", notification_devices.fire_alarm_horn]
      data << ["Fire Alarm Horn (WP)", notification_devices.fire_alarm_horn_wp]
      data << ["Fire Alarm Horn w/ Strobe", notification_devices.fire_alarm_horn_with_strobe]
      data << ["Fire Alarm Horn w/ Strobe (WP)", notification_devices.fire_alarm_horn_with_strobe_wp]
  
      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "cccccc"
        self.row_colors = ["f0f0f0", "ffffff"]
      end
  
      pdf.move_down 20
    else
      pdf.text "No Notification Devices data available.", size: 14, style: :italic
      pdf.move_down 10
    end
  end
  
  
  

  def set_notification
    @notification = Notification.find(params[:id])
  end

  def set_supplier
    @supplier = Supplier.find(params[:supplier_id])
  end
end
