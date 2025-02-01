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
      Rails.logger.info "Params received: #{params.inspect}"

      @supplier = Supplier.find(params[:supplier_id])
      @notification = Notification.find(params[:id])

      # Ensure required fields are provided
      if params[:membership_type].blank? || params[:receive_evaluation_report].nil?
        redirect_to manage_membership_notification_path(@notification, supplier_id: @supplier.id),
                    alert: "Please select all required fields."
        return
      end

      ActiveRecord::Base.transaction do
        # Update supplier details
        @supplier.update!(
          membership_type: params[:membership_type],
          receive_evaluation_report: params[:receive_evaluation_report] == "true",
          status: "approved"
        )

        # Handle membership type
        case params[:membership_type]
        when "projects"
          selected_projects = params[:project_ids] || []
          @supplier.projects = Project.where(id: selected_projects)
          Rails.logger.info "Projects assigned: #{@supplier.projects.pluck(:id)}"
        when "systems"
          selected_subsystems = params[:subsystem_ids] || []
          @supplier.subsystems = Subsystem.where(id: selected_subsystems)
          Rails.logger.info "Subsystems assigned: #{@supplier.subsystems.pluck(:id)}"
        end

        # Handle Manufacturer/Vendor specific requirements
        if @supplier.registration_type == "Manufacturer / Vendor"
          if @supplier.subsystems.blank?
            redirect_to manage_membership_notification_path(@notification, supplier_id: @supplier.id),
                        alert: "Please select at least one subsystem."
            return
          end

          if @supplier.purpose == "Already Quoted & Need Evaluation" && @supplier.evaluation_type.blank?
            redirect_to manage_membership_notification_path(@notification, supplier_id: @supplier.id),
                        alert: "Please select an evaluation type."
            return
          end
        end

        # Resolve notification
        @notification.update!(status: "resolved")
      end

      redirect_to suppliers_path, notice: "#{@supplier.supplier_name} has been approved."
    rescue => e
      Rails.logger.error "Error approving supplier: #{e.message}"
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
