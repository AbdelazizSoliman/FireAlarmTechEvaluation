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
      if params[:membership_type] == "gold"
        selected_projects = params[:project_ids] || []
        @supplier.projects = Project.where(id: selected_projects)
      elsif params[:membership_type] == "silver"
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
  

  private

  def set_notification
    @notification = Notification.find(params[:id])
  end

  def set_supplier
    @supplier = Supplier.find(params[:supplier_id])
  end
end
