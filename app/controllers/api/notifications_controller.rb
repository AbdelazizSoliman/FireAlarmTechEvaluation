module Api
  class NotificationsController < ApplicationController
    before_action :set_notification, only: [:manage_membership, :approve_supplier, :reject_supplier]
    before_action :set_supplier, only: [:manage_membership, :approve_supplier, :reject_supplier]

    def index
      @notifications = Notification.where(read: false).order(created_at: :desc)
      render json: @notifications
    end

    def manage_membership
      @projects = Project.all
      @subsystems = Subsystem.all

      render json: { projects: @projects, subsystems: @subsystems, supplier: @supplier }
    end

    def approve_supplier
      Rails.logger.info "Params: #{params.inspect}"
    
      @supplier = Supplier.find(params[:supplier_id])
      @notification = Notification.find(params[:id])
    
      if params[:membership_type].blank? || params[:receive_evaluation_report].nil?
        redirect_to manage_membership_notification_path(@notification, supplier_id: @supplier.id), alert: "Please select all required fields."
        return
      end
    
      ActiveRecord::Base.transaction do
        @supplier.update!(
          membership_type: params[:membership_type],
          receive_evaluation_report: params[:receive_evaluation_report] == "true",
          status: "approved"
        )
    
        if params[:membership_type] == "projects"
          selected_projects = params[:project_ids] || []
          @supplier.projects = Project.where(id: selected_projects)
          Rails.logger.info "Projects saved: #{@supplier.projects.pluck(:id)}"
        elsif params[:membership_type] == "systems"
          selected_subsystems = params[:subsystem_ids] || []
          @supplier.subsystems = Subsystem.where(id: selected_subsystems)
          Rails.logger.info "Subsystems saved: #{@supplier.subsystems.pluck(:id)}"
        end
    
        @notification.update!(status: "resolved")
      end
    
      redirect_to suppliers_path, notice: "#{@supplier.supplier_name} has been approved with #{params[:membership_type]} evaluation type."
    rescue => e
      Rails.logger.error "Error in approve_supplier: #{e.message}"
      redirect_to manage_membership_notification_path(@notification, supplier_id: @supplier.id), alert: "Error: #{e.message}"
    end
    

    def reject_supplier
      ActiveRecord::Base.transaction do
        @supplier.update!(status: "rejected")
        @notification.update!(read: true, status: "resolved")
      end

      render json: { message: "#{@supplier.supplier_name} has been rejected." }, status: :ok
    rescue => e
      Rails.logger.error "Error rejecting supplier: #{e.message}"
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def set_notification
      @notification = Notification.find(params[:id])
    end

    def set_supplier
      @supplier = Supplier.find(params[:supplier_id])
    end
  end
end
