module Api
  module Supplier
    class SuppliersController < ApplicationController
      skip_before_action :verify_authenticity_token
      
      def register
        Rails.logger.info "Received registration params: #{params.inspect}" # ✅ Debugging log
      
        supplier = ::Supplier.new(supplier_params.except(:projects, :project_scopes, :systems, :subsystems)) # Exclude IDs from initial save
      
        ActiveRecord::Base.transaction do
          if supplier.save
            # ✅ Convert IDs into ActiveRecord objects
            supplier.projects = Project.where(id: params[:supplier][:projects]) if params[:supplier][:projects].present?
            supplier.project_scopes = ProjectScope.where(id: params[:supplier][:project_scopes]) if params[:supplier][:project_scopes].present?
            supplier.systems = System.where(id: params[:supplier][:systems]) if params[:supplier][:systems].present?
            supplier.subsystems = Subsystem.where(id: params[:supplier][:subsystems]) if params[:supplier][:subsystems].present?
      
            supplier.save! # Save the updated associations
      
            notification = Notification.create!(
              title: "New Supplier Registration",
              body: "#{supplier.supplier_name} registered. Review and approve.",
              notifiable: supplier,
              status: "pending",
              notification_type: "registration",
              additional_data: {
                projects: supplier.projects.map(&:id),
                project_scopes: supplier.project_scopes.map(&:id),
                systems: supplier.systems.map(&:id),
                subsystems: supplier.subsystems.map(&:id)
              }
            )
      
            render json: { message: "Supplier registered successfully", notification_id: notification.id }, status: :created
          else
            Rails.logger.error "Registration failed: #{supplier.errors.full_messages}" # ✅ Debugging log
            render json: { errors: supplier.errors.full_messages }, status: :unprocessable_entity
          end
        end
      rescue StandardError => e
        Rails.logger.error "Error in supplier registration: #{e.message}" # ✅ Debugging log
        render json: { error: e.message }, status: :unprocessable_entity
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
        notification = Notification.find(params[:id])
        supplier = notification.notifiable
        
        supplier.update!(status: "rejected")
        notification.update!(status: "resolved")
      
        render json: { message: "Supplier rejected successfully" }
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
      
      private
      
      def supplier_params
        params.require(:supplier).permit(
          :supplier_name,
          :supplier_category,
          :total_years_in_saudi_market,
          :phone,
          :supplier_email,
          :password,
          :password_confirmation,
          :registration_type,
          :purpose,
          :evaluation_type,
          projects: [],           # Allow an array of project IDs
          project_scopes: [],     # Allow an array of project scope IDs
          systems: [],            # Allow an array of system IDs
          subsystems: []          # Allow an array of subsystem IDs
        )
      end
      
      
      
    end
  end
end
