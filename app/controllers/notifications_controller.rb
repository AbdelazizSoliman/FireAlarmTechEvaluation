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
      case @notification.notification_type
      when "registration"
        redirect_to manage_membership_notification_path(@notification)
      when "evaluation"
        if @notification.notifiable.is_a?(Subsystem)
          subsystem = @notification.notifiable
          @supplier_data = subsystem.supplier_data.first
          @fire_alarm_control_panel = subsystem.fire_alarm_control_panels.first
          @detectors_field_device = subsystem.detectors_field_devices.first
        else
          redirect_to notifications_path, alert: "Invalid notifiable type for evaluation."
        end
      else
        redirect_to notifications_path, alert: "Unknown notification type."
      end
    when :pdf
      if @notification.notifiable.is_a?(Subsystem)
        subsystem = @notification.notifiable
        @supplier_data = subsystem.supplier_data.first
        @fire_alarm_control_panel = subsystem.fire_alarm_control_panels.first
        @detectors_field_device = subsystem.detectors_field_devices.first
  
        pdf = Prawn::Document.new
        pdf.text "Evaluation Report", size: 18, style: :bold
        pdf.move_down 20
  
        # Add Supplier Data
        if @supplier_data
          pdf.text "Supplier Data", size: 16, style: :bold
          pdf.move_down 10
          @supplier_data.attributes.each do |key, value|
            pdf.text "#{key.humanize}: #{value}"
          end
          pdf.move_down 20
        end
  
        # Add Fire Alarm Control Panel Data
        if @fire_alarm_control_panel
          pdf.text "Fire Alarm Control Panel Details", size: 16, style: :bold
          pdf.move_down 10
          @fire_alarm_control_panel.attributes.each do |key, value|
            pdf.text "#{key.humanize}: #{value}"
          end
          pdf.move_down 20
        end
  
        # Add Detectors Field Device Data
        if @detectors_field_device
          pdf.text "Detectors Field Devices", size: 16, style: :bold
          pdf.move_down 10
          @detectors_field_device.attributes.each do |key, value|
            next unless key.ends_with?('_value')
  
            detector_type = key.sub('_value', '').humanize
            pdf.text "Type: #{detector_type}"
            pdf.text "Value: #{@detectors_field_device[key]}"
            pdf.text "Unit Rate: #{@detectors_field_device["#{key.sub('_value', '_unit_rate')}"]}"
            pdf.text "Amount: #{@detectors_field_device["#{key.sub('_value', '_amount')}"]}"
            pdf.text "Notes: #{@detectors_field_device["#{key.sub('_value', '_notes')}"]}"
            pdf.move_down 10
          end
        end
  
        send_data pdf.render,
                  filename: "evaluation_report_#{@notification.id}.pdf",
                  type: "application/pdf",
                  disposition: "inline"
      else
        redirect_to notifications_path, alert: "Invalid notifiable type for evaluation."
      end
    when :xlsx
      if @notification.notifiable.is_a?(Subsystem)
        subsystem = @notification.notifiable
        @supplier_data = subsystem.supplier_data.first
        @fire_alarm_control_panel = subsystem.fire_alarm_control_panels.first
        @detectors_field_device = subsystem.detectors_field_devices.first
        render xlsx: "show", template: "notifications/show_excel", filename: "evaluation_report.xlsx"
      else
        redirect_to notifications_path, alert: "Invalid notifiable type for evaluation."
      end
    else
      redirect_to notifications_path, alert: "Unsupported format."
    end
  end
  
  

  private

  def set_notification
    @notification = Notification.find(params[:id])
  end

  def set_supplier
    @supplier = Supplier.find(params[:supplier_id])
  end
end
