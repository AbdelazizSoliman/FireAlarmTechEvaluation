class NotificationsController < ApplicationController
  before_action :set_notification, only: [:manage_membership, :approve_supplier, :reject_supplier]
  before_action :set_supplier, only: [:manage_membership, :approve_supplier, :reject_supplier]

  def index
    @notifications = Notification.all

    respond_to do |format|
      format.html { render :index } # Default HTML view
      format.json { render json: @notifications.order(created_at: :desc) }
    end
  end
  def manage_membership
    @supplier = Supplier.find(params[:supplier_id])
    @projects = Project.all
    @subsystems = Subsystem.all
  end

  def approve_supplier
    @notification = Notification.find(params[:id])
    @supplier = @notification.notifiable
  
    begin
      ActiveRecord::Base.transaction do
        # ✅ Update supplier's status and receive_evaluation_report
        @supplier.update!(
          receive_evaluation_report: params[:receive_evaluation_report] == "true",
          status: "approved"
        )
  
        # ✅ Update project approvals (if any are selected)
        if params[:project_ids].present?
          @supplier.projects.where(id: params[:project_ids]).update_all(approved: true)
        end
  
        # ✅ Update project scope approvals
        if params[:project_scope_ids].present?
          @supplier.project_scopes.where(id: params[:project_scope_ids]).update_all(approved: true)
        end
  
        # ✅ Update systems approvals
        if params[:system_ids].present?
          @supplier.systems.where(id: params[:system_ids]).update_all(approved: true)
        end
  
        # ✅ Update subsystems approvals
        if params[:subsystem_ids].present?
          @supplier.subsystems.where(id: params[:subsystem_ids]).update_all(approved: true)
        end
  
        # ✅ Mark notification as resolved
        @notification.update!(status: "resolved")
      end
  
      flash[:notice] = "Supplier approved successfully."
    rescue => e
      flash[:alert] = "Error approving supplier: #{e.message}"
    end
  
    redirect_to notifications_path
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

    respond_to do |format|
      format.html { handle_html_request } # Default HTML view
      format.json do
        render json: {
          notification: @notification,
          data: @notification.notifiable
        }
      end
      format.pdf { handle_pdf_request }
      format.xlsx { handle_xlsx_request }
      format.any { redirect_to notifications_path, alert: "Unsupported format." }
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

      # Existing Sections
      add_pdf_section(pdf, "Supplier Data", @supplier_data)
      add_pdf_section(pdf, "Product Data", @product_data)
      add_pdf_section(pdf, "Fire Alarm Control Panel", @fire_alarm_control_panel)
      add_pdf_section(pdf, "Graphic Systems", @graphic_system)
      add_pdf_detectors(pdf, @detectors_field_device)
      add_pdf_section(pdf, "Manual Pull Station", @manual_pull_station)
      add_pdf_door_holders(pdf, @door_holder)
      add_pdf_notification_devices(pdf, @notification_devices)
      add_pdf_isolation(pdf, @isolation)

      # New Sections
      add_pdf_connection_betweens(pdf, @connection_betweens)
      add_pdf_interface_with_other(pdf, @interface_with_other_systems)
      add_pdf_evacuation_systems(pdf, @evacuation_systems)
      add_pdf_prerecorded_messages(pdf, @prerecorded_messages)
      add_pdf_telephone_systems(pdf, @telephone_systems)
      add_pdf_spare_parts(pdf, @spare_parts)
      add_pdf_scope_of_work(pdf, @scope_of_work)
      add_pdf_material_delivery(pdf, @material_delivery)
      add_pdf_general_commercial(pdf, @general_commercial_data)

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
    @isolations = @subsystem.isolations.first
    @connection_betweens = @subsystem.connection_betweens.first
    @interface_with_other_systems = @subsystem.interface_with_other_systems.first
    @evacuation_systems = @subsystem.evacuation_systems.first
    @prerecorded_message_audio_modules = @subsystem.prerecorded_message_audio_modules.first
    @telephone_systems = @subsystem.telephone_systems.first
    @spare_parts = @subsystem.spare_parts.first
    @scope_of_works = @subsystem.scope_of_works.first
    @material_and_deliveries = @subsystem.material_and_deliveries.first
    @general_commercial_data = @subsystem.general_commercial_data.first
    Rails.logger.debug "Isolation Data: #{@isolation.inspect}"
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
        next unless key.ends_with?("_value")

        detector_type = key.sub("_value", "").humanize
        pdf.text "Type: #{detector_type}"
        pdf.text "Value: #{value}"
        pdf.text "Unit Rate: #{detectors["#{key.sub("_value", "_unit_rate")}"]}"
        pdf.text "Amount: #{detectors["#{key.sub("_value", "_amount")}"]}"
        pdf.text "Notes: #{detectors["#{key.sub("_value", "_notes")}"]}"
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
        { type: "total_no_of_devices", label: "Total Number of Devices" },
        { type: "total_no_of_relays", label: "Total Number of Relays" },
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

  def add_pdf_isolation(pdf, isolation)
    Rails.logger.debug "Isolation passed to PDF: #{isolation.inspect}"
    if isolation
      pdf.text "Isolation Devices", size: 16, style: :bold
      pdf.move_down 10

      # Build a table with headers
      data = []
      data << ["Attribute", "Value"]

      # Add each attribute to the table
      data << ["Built-In Fault Isolator for Each Detector", isolation.built_in_fault_isolator_for_each_detector]
      data << ["Built-In Fault Isolator for Each MCP/BG", isolation.built_in_fault_isolator_for_each_mcp_bg]
      data << ["Built-In Fault Isolator for Each Sounder/Horn", isolation.built_in_fault_isolator_for_each_sounder_horn]
      data << ["Built-In Fault Isolator for Monitor/Control Modules", isolation.built_in_fault_isolator_for_monitor_control_modules]
      data << ["Grouping for Each 12-15 (No.)", isolation.grouping_for_each_12_15]

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "cccccc"
        self.row_colors = ["f0f0f0", "ffffff"]
      end

      pdf.move_down 20
    else
      pdf.text "No Isolation Devices data available.", size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_connection_betweens(pdf, connection_betweens)
    if connection_betweens
      pdf.text "Connection Between FACPs", size: 16, style: :bold
      pdf.move_down 10
      data = [["Attribute", "Value"]]
      data << ["Connection Type", connection_betweens.connection_type]
      data << ["Network Module", connection_betweens.network_module]
      data << ["Cables for Connection", connection_betweens.cables_for_connection]

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "cccccc"
      end
      pdf.move_down 20
    else
      pdf.text "No Connection Between FACPs data available.", size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_interface_with_other(pdf, interface_with_other)
    if interface_with_other
      pdf.text "Interface with Other Systems", size: 16, style: :bold
      pdf.move_down 10
      data = [["Attribute", "Value"]]
      interface_with_other.attributes.each do |key, value|
        data << [key.humanize, value]
      end

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "cccccc"
      end
      pdf.move_down 20
    else
      pdf.text "No Interface with Other Systems data available.", size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_evacuation_systems(pdf, evacuation_systems)
    if evacuation_systems
      pdf.text "Evacuation Systems", size: 16, style: :bold
      pdf.move_down 10
      data = [["Attribute", "Value"]]
      evacuation_systems.attributes.each do |key, value|
        data << [key.humanize, value]
      end

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "cccccc"
      end
      pdf.move_down 20
    else
      pdf.text "No Evacuation Systems data available.", size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_prerecorded_messages(pdf, prerecorded_messages)
    if prerecorded_messages
      pdf.text "Prerecorded Messages/Audio Modules", size: 16, style: :bold
      pdf.move_down 10
      data = [["Attribute", "Value"]]
      prerecorded_messages.attributes.each do |key, value|
        data << [key.humanize, value]
      end

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "cccccc"
      end
      pdf.move_down 20
    else
      pdf.text "No Prerecorded Messages/Audio Modules data available.", size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_telephone_systems(pdf, telephone_systems)
    if telephone_systems
      pdf.text "Telephone System", size: 16, style: :bold
      pdf.move_down 10
      data = [["Attribute", "Value"]]
      telephone_systems.attributes.each do |key, value|
        data << [key.humanize, value]
      end

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "cccccc"
      end
      pdf.move_down 20
    else
      pdf.text "No Telephone System data available.", size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_spare_parts(pdf, spare_parts)
    if spare_parts
      pdf.text "Spare Parts", size: 16, style: :bold
      pdf.move_down 10
      data = [["Attribute", "Value"]]
      spare_parts.attributes.each do |key, value|
        data << [key.humanize, value]
      end

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "cccccc"
      end
      pdf.move_down 20
    else
      pdf.text "No Spare Parts data available.", size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_scope_of_work(pdf, scope_of_work)
    if scope_of_work
      pdf.text "Scope of Work (SOW)", size: 16, style: :bold
      pdf.move_down 10
      data = [["Attribute", "Value"]]
      scope_of_work.attributes.each do |key, value|
        data << [key.humanize, value]
      end

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "cccccc"
      end
      pdf.move_down 20
    else
      pdf.text "No Scope of Work data available.", size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_scope_of_work(pdf, scope_of_work)
    if scope_of_work
      pdf.text "Scope of Work (SOW)", size: 16, style: :bold
      pdf.move_down 10
      data = [["Attribute", "Value"]]
      scope_of_work.attributes.each do |key, value|
        data << [key.humanize, value]
      end

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "cccccc"
      end
      pdf.move_down 20
    else
      pdf.text "No Scope of Work data available.", size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_general_commercial(pdf, general_commercial)
    if general_commercial
      pdf.text "General & Commercial Data", size: 16, style: :bold
      pdf.move_down 10
      data = [["Attribute", "Value"]]
      general_commercial.attributes.each do |key, value|
        data << [key.humanize, value]
      end

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "cccccc"
      end
      pdf.move_down 20
    else
      pdf.text "No General & Commercial Data available.", size: 14, style: :italic
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
