module Api
  class NotificationsController < ApplicationController
    before_action :set_notification, only: [:manage_membership, :approve_supplier, :reject_supplier]
    before_action :set_supplier, only: [:manage_membership, :approve_supplier, :reject_supplier]

    def index
      notifications = Notification.order(created_at: :desc)
      render json: notifications.map { |notification| 
        {
          id: notification.id,
          title: notification.title,
          body: notification.body,
          read: notification.read,
          status: notification.status,
          notification_type: notification.notification_type,
          created_at: notification.created_at.strftime("%Y-%m-%d %H:%M:%S")
        }
      }
    end
    

    def generate_link(notification)
      case notification.notification_type
      when "registration"
        "/suppliers/#{notification.notifiable_id}"
      when "membership"
        "/notifications/#{notification.id}/manage_membership"
      when "evaluation"
        "/notifications/#{notification.id}/show"
      when "approval"
        "/suppliers/#{notification.notifiable_id}"
      else
        "/notifications/#{notification.id}" # Default link
      end
    end

    def manage_membership
      @projects = Project.all
      @subsystems = Subsystem.all

      render json: { projects: @projects, subsystems: @subsystems, supplier: @supplier }
    end

    def approve_supplier
      @notification = Notification.find(params[:id])
      @supplier = @notification.notifiable
    
      ActiveRecord::Base.transaction do
        # Update supplier details
        @supplier.update!(
          receive_evaluation_report: params[:receive_evaluation_report] == "true",
          status: "approved"
        )
    
        # Approve selected projects
        @supplier.projects.where(id: params[:project_ids]).update_all(approved: true)
    
        # Approve selected project scopes
        @supplier.project_scopes.where(id: params[:project_scope_ids]).update_all(approved: true)
    
        # Approve selected systems
        @supplier.systems.where(id: params[:system_ids]).update_all(approved: true)
    
        # Approve selected subsystems
        @supplier.subsystems.where(id: params[:subsystem_ids]).update_all(approved: true)
    
        # Resolve notification
        @notification.update!(status: "resolved")
      end
    
      redirect_to notifications_path, notice: "Supplier approved successfully."
    rescue => e
      redirect_to manage_membership_notification_path(@notification, supplier_id: @supplier.id),
                  alert: "Error: #{e.message}"
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
