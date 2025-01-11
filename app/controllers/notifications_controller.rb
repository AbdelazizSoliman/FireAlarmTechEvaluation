class NotificationsController < ApplicationController
  before_action :set_notification, only: [:manage_membership, :approve_supplier, :reject_supplier]
  before_action :set_supplier, only: [:manage_membership, :approve_supplier, :reject_supplier]

  def index
    @notifications = Notification.where(read: false).order(created_at: :desc)
    # render json: @notifications
  end

  def manage_membership
    @supplier = Supplier.find(params[:supplier_id])
    @projects = Project.all
    @subsystems = Subsystem.all
  end

  def approve_supplier
    if params[:membership_type].blank? || params[:receive_evaluation_report].nil?
      redirect_to manage_membership_notification_path(@notification, supplier_id: @supplier.id), alert: "Please select all required fields."
      return
    end
  
    ActiveRecord::Base.transaction do
      # Update supplier details
      @supplier.update!(
        membership_type: params[:membership_type],
        receive_evaluation_report: params[:receive_evaluation_report] == "true",
        status: "approved"
      )
  
      # Handle project or subsystem permissions
      if params[:membership_type] == "gold"
        project_ids = params[:project_ids] || []
        @supplier.projects = Project.where(id: project_ids)
      elsif params[:membership_type] == "silver"
        subsystem_ids = params[:subsystem_ids] || []
        @supplier.subsystems = Subsystem.where(id: subsystem_ids)
      end
  
      # Mark the notification as resolved
      @notification.update!(read: true, status: "resolved")
    end
  
    redirect_to notifications_path, notice: "#{@supplier.supplier_name} has been approved with #{params[:membership_type].capitalize} membership."
  rescue => e
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
  

  private

  def set_notification
    @notification = Notification.find(params[:id])
  end

  def set_supplier
    @supplier = Supplier.find(params[:supplier_id])
  end
end
