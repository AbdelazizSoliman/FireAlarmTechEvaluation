class NotificationsController < ApplicationController
  before_action :set_notification, only: %i[manage_membership approve_supplier reject_supplier]
  before_action :set_supplier, only: %i[manage_membership approve_supplier reject_supplier]

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
    Rails.logger.info 'Starting approve_supplier action'
    @notification = Notification.find(params[:id])
    @supplier = @notification.notifiable
  
    ActiveRecord::Base.transaction do
      # Update supplier's status and receive_evaluation_report
      @supplier.update!(
        receive_evaluation_report: params[:receive_evaluation_report] == 'true',
        status: 'approved'
      )
  
      # Update join table entries for projects, project scopes, systems, and subsystems
      if params[:project_ids].present?
        ActiveRecord::Base.connection.execute("
          UPDATE projects_suppliers
          SET approved = true
          WHERE supplier_id = #{@supplier.id} AND project_id IN (#{params[:project_ids].join(',')})
        ")
      end
  
      if params[:project_scope_ids].present?
        ActiveRecord::Base.connection.execute("
          UPDATE project_scopes_suppliers
          SET approved = true
          WHERE supplier_id = #{@supplier.id} AND project_scope_id IN (#{params[:project_scope_ids].join(',')})
        ")
      end
  
      if params[:system_ids].present?
        ActiveRecord::Base.connection.execute("
          UPDATE systems_suppliers
          SET approved = true
          WHERE supplier_id = #{@supplier.id} AND system_id IN (#{params[:system_ids].join(',')})
        ")
      end
  
      if params[:subsystem_ids].present?
        ActiveRecord::Base.connection.execute("
          UPDATE subsystems_suppliers
          SET approved = true
          WHERE supplier_id = #{@supplier.id} AND subsystem_id IN (#{params[:subsystem_ids].join(',')})
        ")
      end
  
      # Mark notification as resolved
      @notification.update!(status: 'resolved')
  
      # Reload supplier to pick up approved join table changes
      @supplier.reload
  
      Rails.logger.info "After update, supplier purpose: #{@supplier.purpose.inspect}, receive_rfq_mail: #{@supplier.receive_rfq_mail.inspect}"
      Rails.logger.info "Approved subsystems: #{@supplier.approved_subsystems.pluck(:name).inspect}"
  
      # Trigger RFQ email only if conditions are met
      if @supplier.purpose == 'Need to Quote' && @supplier.receive_rfq_mail
        Rails.logger.info "Triggering RFQ email for supplier #{@supplier.id}"
        SupplierMailer.with(supplier: @supplier).rfq_email.deliver_now
      else
        Rails.logger.info "Conditions not met for sending RFQ email"
      end
    end
  
    redirect_to notifications_path, notice: 'Supplier approved successfully.'
  rescue StandardError => e
    redirect_to manage_membership_notification_path(@notification, supplier_id: @supplier.id),
                alert: "Error: #{e.message}"
  end
  

  def reject_supplier
    ActiveRecord::Base.transaction do
      @supplier.update!(status: 'rejected')
      @notification.update!(read: true, status: 'resolved')
    end

    redirect_to notifications_path, notice: "#{@supplier.supplier_name} has been rejected."
  rescue StandardError => e
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
      format.any { redirect_to notifications_path, alert: 'Unsupported format.' }
    end
  end

  private

  def handle_html_request
    case @notification.notification_type
    when 'registration'
      redirect_to manage_membership_notification_path(@notification)
    when 'evaluation'
      if @notification.notifiable.is_a?(Subsystem)
        assign_subsystem_data
      else
        redirect_to notifications_path, alert: 'Invalid notifiable type for evaluation.'
      end
    else
      redirect_to notifications_path, alert: 'Unknown notification type.'
    end
  end

  def handle_pdf_request
    if @notification.notifiable.is_a?(Subsystem)
      assign_subsystem_data

      pdf = Prawn::Document.new
      pdf.text 'Evaluation Report', size: 18, style: :bold
      pdf.move_down 20

      # ✅ Existing Sections
      add_pdf_section(pdf, 'Supplier Data', @supplier_data)
      add_pdf_section(pdf, 'Product Data', @product_data)
      add_pdf_section(pdf, 'Fire Alarm Control Panel', @fire_alarm_control_panel)
      add_pdf_section(pdf, 'Graphic Systems', @graphic_system)
      add_pdf_detectors(pdf, @detectors_field_device)
      add_pdf_section(pdf, 'Manual Pull Station', @manual_pull_station)
      add_pdf_door_holders(pdf, @door_holder)
      add_pdf_notification_devices(pdf, @notification_devices)
      add_pdf_isolation(pdf, @isolations) # Ensure `@isolations` is used instead of `@isolation`

      # ✅ New Sections (Ensuring Proper Argument Handling)
      add_pdf_section(pdf, 'Connection Between FACPs', @connection_betweens)
      add_pdf_section(pdf, 'Interface with Other Systems', @interface_with_other_systems)
      add_pdf_section(pdf, 'Evacuation Systems', @evacuation_systems)
      add_pdf_section(pdf, 'Prerecorded Messages Audio Module', @prerecorded_message_audio_modules)
      add_pdf_section(pdf, 'Telephone System', @telephone_systems)
      add_pdf_section(pdf, 'Spare Parts', @spare_parts)
      add_pdf_section(pdf, 'Scope of Work (SOW)', @scope_of_works)
      add_pdf_section(pdf, 'Material & Delivery', @material_and_deliveries)
      add_pdf_section(pdf, 'General & Commercial Data', @general_commercial_data)

      send_data pdf.render,
                filename: "evaluation_report_#{@notification.id}.pdf",
                type: 'application/pdf',
                disposition: 'inline'
    else
      redirect_to notifications_path, alert: 'Invalid notifiable type for evaluation.'
    end
  end

  def handle_xlsx_request
    if @notification.notifiable.is_a?(Subsystem)
      assign_subsystem_data

      render xlsx: 'show', template: 'notifications/show_excel', filename: 'evaluation_report.xlsx'
    else
      redirect_to notifications_path, alert: 'Invalid notifiable type for evaluation.'
    end
  end

  def assign_subsystem_data
    @subsystem = @notification.notifiable
    additional_data = JSON.parse(@notification.additional_data || '{}')
    supplier_id = additional_data['supplier_id']

    @supplier_data = @subsystem.supplier_data.find_by(supplier_id: supplier_id)
    @product_data = @subsystem.product_data.find_by(supplier_id: supplier_id)
    @fire_alarm_control_panel = @subsystem.fire_alarm_control_panels.find_by(supplier_id: supplier_id)
    @graphic_system = @subsystem.graphic_systems.find_by(supplier_id: supplier_id)
    @detectors_field_device = @subsystem.detectors_field_devices.find_by(supplier_id: supplier_id)
    @manual_pull_station = @subsystem.manual_pull_stations.find_by(supplier_id: supplier_id)
    @door_holder = @subsystem.door_holders.find_by(supplier_id: supplier_id)
    @notification_devices = @subsystem.notification_devices.find_by(supplier_id: supplier_id)
    @isolations = @subsystem.isolations.find_by(supplier_id: supplier_id)
    @connection_betweens = @subsystem.connection_betweens.find_by(supplier_id: supplier_id)
    @interface_with_other_systems = @subsystem.interface_with_other_systems.find_by(supplier_id: supplier_id)
    @evacuation_systems = @subsystem.evacuation_systems.find_by(supplier_id: supplier_id)
    @prerecorded_message_audio_modules = @subsystem.prerecorded_message_audio_modules.find_by(supplier_id: supplier_id)
    @telephone_systems = @subsystem.telephone_systems.find_by(supplier_id: supplier_id)
    @spare_parts = @subsystem.spare_parts.find_by(supplier_id: supplier_id)
    @scope_of_works = @subsystem.scope_of_works.find_by(supplier_id: supplier_id)
    @material_and_deliveries = @subsystem.material_and_deliveries.find_by(supplier_id: supplier_id)
    @general_commercial_data = @subsystem.general_commercial_data.find_by(supplier_id: supplier_id)
  end

  def add_pdf_section(pdf, section_title, data)
    if data.present?
      pdf.text section_title, size: 16, style: :bold
      pdf.move_down 10

      table_data = [%w[Attribute Value]] # Ensure this is always an array of arrays

      data.attributes.each do |key, value|
        # Convert non-string values to strings to avoid errors
        table_data << [key.humanize.to_s, value.to_s]
      end

      # Ensure table_data has at least two rows before creating a table
      if table_data.length > 1
        pdf.table(table_data, header: true, width: pdf.bounds.width) do
          row(0).font_style = :bold
          row(0).background_color = 'cccccc'
          self.row_colors = %w[f0f0f0 ffffff]
        end
      else
        pdf.text "No data available for #{section_title}.", size: 12, style: :italic
      end

      pdf.move_down 20
    else
      pdf.text "#{section_title} data not available.", size: 12, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_detectors(pdf, detectors)
    if detectors.present?
      pdf.text 'Detectors Field Devices', size: 16, style: :bold
      pdf.move_down 10

      table_data = [['Type', 'Value', 'Unit Rate', 'Amount', 'Notes']]

      detectors.attributes.each do |key, value|
        next unless key.ends_with?('_value')

        detector_type = key.sub('_value', '').humanize
        row = [
          detector_type,
          value.to_s,
          detectors["#{key.sub('_value', '_unit_rate')}"].to_s,
          detectors["#{key.sub('_value', '_amount')}"].to_s,
          detectors["#{key.sub('_value', '_notes')}"].to_s
        ]
        table_data << row
      end

      if table_data.length > 1
        pdf.table(table_data, header: true, width: pdf.bounds.width) do
          row(0).font_style = :bold
          row(0).background_color = 'cccccc'
          self.row_colors = %w[f0f0f0 ffffff]
        end
      else
        pdf.text 'No detectors data available.', size: 12, style: :italic
      end

      pdf.move_down 20
    else
      pdf.text 'No Detectors Field Devices data available.', size: 12, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_door_holders(pdf, door_holders)
    if door_holders.present?
      pdf.text 'Door Holders', size: 16, style: :bold
      pdf.move_down 10

      table_data = [['Type', 'Value', 'Unit Rate', 'Amount', 'Notes']]

      [
        { type: 'total_no_of_devices', label: 'Total Number of Devices' },
        { type: 'total_no_of_relays', label: 'Total Number of Relays' }
      ].each do |attribute|
        type_key = attribute[:type]
        holder_label = attribute[:label]

        row = [
          holder_label,
          door_holders[type_key].to_s,
          door_holders["#{type_key}_unit_rate"].to_s,
          door_holders["#{type_key}_amount"].to_s,
          door_holders["#{type_key}_notes"].to_s
        ]
        table_data << row
      end

      if table_data.length > 1
        pdf.table(table_data, header: true, width: pdf.bounds.width) do
          row(0).font_style = :bold
          row(0).background_color = 'cccccc'
          self.row_colors = %w[f0f0f0 ffffff]
        end
      else
        pdf.text 'No door holders data available.', size: 12, style: :italic
      end

      pdf.move_down 20
    else
      pdf.text 'No Door Holders data available.', size: 12, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_notification_devices(pdf, notification_devices)
    if notification_devices
      pdf.text 'Notification Devices', size: 16, style: :bold
      pdf.move_down 10

      # Build a 2-column table with headers
      data = []
      data << %w[Attribute Value]

      data << ['Notification Addressing', notification_devices.notification_addressing]
      data << ['Fire Alarm Strobe', notification_devices.fire_alarm_strobe]
      data << ['Fire Alarm Strobe (WP)', notification_devices.fire_alarm_strobe_wp]
      data << ['Fire Alarm Horn', notification_devices.fire_alarm_horn]
      data << ['Fire Alarm Horn (WP)', notification_devices.fire_alarm_horn_wp]
      data << ['Fire Alarm Horn w/ Strobe', notification_devices.fire_alarm_horn_with_strobe]
      data << ['Fire Alarm Horn w/ Strobe (WP)', notification_devices.fire_alarm_horn_with_strobe_wp]

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'cccccc'
        self.row_colors = %w[f0f0f0 ffffff]
      end

      pdf.move_down 20
    else
      pdf.text 'No Notification Devices data available.', size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_isolation(pdf, isolation)
    Rails.logger.debug "Isolation passed to PDF: #{isolation.inspect}"
    if isolation
      pdf.text 'Isolation Devices', size: 16, style: :bold
      pdf.move_down 10

      # Build a table with headers
      data = []
      data << %w[Attribute Value]

      # Add each attribute to the table
      data << ['Built-In Fault Isolator for Each Detector', isolation.built_in_fault_isolator_for_each_detector]
      data << ['Built-In Fault Isolator for Each MCP/BG', isolation.built_in_fault_isolator_for_each_mcp_bg]
      data << ['Built-In Fault Isolator for Each Sounder/Horn', isolation.built_in_fault_isolator_for_each_sounder_horn]
      data << ['Built-In Fault Isolator for Monitor/Control Modules',
               isolation.built_in_fault_isolator_for_monitor_control_modules]
      data << ['Grouping for Each 12-15 (No.)', isolation.grouping_for_each_12_15]

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'cccccc'
        self.row_colors = %w[f0f0f0 ffffff]
      end

      pdf.move_down 20
    else
      pdf.text 'No Isolation Devices data available.', size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_connection_betweens(pdf, connection_betweens)
    if connection_betweens
      pdf.text 'Connection Between FACPs', size: 16, style: :bold
      pdf.move_down 10
      data = [%w[Attribute Value]]
      data << ['Connection Type', connection_betweens.connection_type]
      data << ['Network Module', connection_betweens.network_module]
      data << ['Cables for Connection', connection_betweens.cables_for_connection]

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'cccccc'
      end
      pdf.move_down 20
    else
      pdf.text 'No Connection Between FACPs data available.', size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_interface_with_other(pdf)
    # Construct a proper table data structure
    data = []
    # Add header row
    data << %w[Field Value]

    # Assume @notification is the object you’re rendering
    data << ['Title', @notification.title.to_s]
    data << ['Date', @notification.created_at.strftime('%Y-%m-%d')]
    # Add more rows as needed

    # Validate that data is an array of arrays
    raise "Table data is not formatted correctly: #{data.inspect}" unless data.all? { |row| row.is_a?(Array) }

    pdf.table(data, header: true, width: pdf.bounds.width) do
      row(0).font_style = :bold
      row(0).background_color = 'cccccc'
    end
  end

  def add_pdf_evacuation_systems(pdf, evacuation_systems)
    if evacuation_systems
      pdf.text 'Evacuation Systems', size: 16, style: :bold
      pdf.move_down 10
      data = [%w[Attribute Value]]
      evacuation_systems.attributes.each do |key, value|
        data << [key.humanize, value]
      end

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'cccccc'
      end
      pdf.move_down 20
    else
      pdf.text 'No Evacuation Systems data available.', size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_prerecorded_messages(pdf, prerecorded_messages)
    if prerecorded_messages
      pdf.text 'Prerecorded Messages/Audio Modules', size: 16, style: :bold
      pdf.move_down 10
      data = [%w[Attribute Value]]
      prerecorded_messages.attributes.each do |key, value|
        data << [key.humanize, value]
      end

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'cccccc'
      end
      pdf.move_down 20
    else
      pdf.text 'No Prerecorded Messages/Audio Modules data available.', size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_telephone_systems(pdf, telephone_systems)
    if telephone_systems
      pdf.text 'Telephone System', size: 16, style: :bold
      pdf.move_down 10
      data = [%w[Attribute Value]]
      telephone_systems.attributes.each do |key, value|
        data << [key.humanize, value]
      end

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'cccccc'
      end
      pdf.move_down 20
    else
      pdf.text 'No Telephone System data available.', size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_spare_parts(pdf, spare_parts)
    if spare_parts
      pdf.text 'Spare Parts', size: 16, style: :bold
      pdf.move_down 10
      data = [%w[Attribute Value]]
      spare_parts.attributes.each do |key, value|
        data << [key.humanize, value]
      end

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'cccccc'
      end
      pdf.move_down 20
    else
      pdf.text 'No Spare Parts data available.', size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_scope_of_work(pdf, scope_of_work)
    if scope_of_work
      pdf.text 'Scope of Work (SOW)', size: 16, style: :bold
      pdf.move_down 10
      data = [%w[Attribute Value]]
      scope_of_work.attributes.each do |key, value|
        data << [key.humanize, value]
      end

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'cccccc'
      end
      pdf.move_down 20
    else
      pdf.text 'No Scope of Work data available.', size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_scope_of_work(pdf, scope_of_work)
    if scope_of_work
      pdf.text 'Scope of Work (SOW)', size: 16, style: :bold
      pdf.move_down 10
      data = [%w[Attribute Value]]
      scope_of_work.attributes.each do |key, value|
        data << [key.humanize, value]
      end

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'cccccc'
      end
      pdf.move_down 20
    else
      pdf.text 'No Scope of Work data available.', size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def add_pdf_general_commercial(pdf, general_commercial)
    if general_commercial
      pdf.text 'General & Commercial Data', size: 16, style: :bold
      pdf.move_down 10
      data = [%w[Attribute Value]]
      general_commercial.attributes.each do |key, value|
        data << [key.humanize, value]
      end

      pdf.table(data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'cccccc'
      end
      pdf.move_down 20
    else
      pdf.text 'No General & Commercial Data available.', size: 14, style: :italic
      pdf.move_down 10
    end
  end

  def set_notification
    @notification = Notification.find(params[:id])
  end

  def set_supplier
    @supplier = @notification.notifiable

    return if @supplier.is_a?(Supplier)

    Rails.logger.error "Error: Expected Supplier but got #{@supplier.inspect}"
    redirect_to notifications_path, alert: 'Error: Supplier not found.'
  end
end
