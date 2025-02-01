module Api
  module Supplier
    class SuppliersController < ApplicationController
      skip_before_action :verify_authenticity_token
      
      def register
        supplier_params[:project_scopes] ||= supplier_params.delete(:projectScopes)
        supplier = ::Supplier.new(supplier_params)
      
        ActiveRecord::Base.transaction do
          if supplier.save
            selected_projects = Project.where(id: params[:supplier][:projects]) rescue []
            selected_scopes = ProjectScope.where(id: params[:supplier][:project_scopes] || [])
            selected_systems = System.where(id: params[:supplier][:systems]) rescue []
            selected_subsystems = Subsystem.where(id: params[:supplier][:subsystems]) rescue []
      
            supplier.projects << selected_projects
            supplier.project_scopes << selected_scopes
            supplier.systems << selected_systems
            supplier.subsystems << selected_subsystems
      
            notification = Notification.create!(
              title: "New Supplier Registration",
              body: "#{supplier.supplier_name} registered. Review and approve.",
              notifiable: supplier,
              status: "pending",
              notification_type: "registration",
              additional_data: {
                projects: selected_projects.map(&:id),
                project_scopes: selected_scopes.map(&:id),
                systems: selected_systems.map(&:id),
                subsystems: selected_subsystems.map(&:id)
              }
            )
      
            render json: { message: "Supplier registered successfully", notification_id: notification.id }, status: :created
          else
            render json: { errors: supplier.errors.full_messages }, status: :unprocessable_entity
          end
        end
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
      
      def show_registration_details
        notification = Notification.find(params[:id])
        supplier = notification.notifiable
        
        selected_projects = Project.where(id: notification.additional_data["projects"])
        selected_scopes = ProjectScope.where(id: notification.additional_data["project_scopes"])
        selected_systems = System.where(id: notification.additional_data["systems"])
        selected_subsystems = Subsystem.where(id: notification.additional_data["subsystems"])
        
        render json: {
          supplier: supplier,
          projects: selected_projects,
          project_scopes: selected_scopes,
          systems: selected_systems,
          subsystems: selected_subsystems
        }
      end
      
      def approve_supplier
        notification = Notification.find(params[:id])
        supplier = notification.notifiable
        
        selected_projects = Project.where(id: params[:project_ids])
        selected_scopes = ProjectScope.where(id: params[:project_scope_ids])
        selected_systems = System.where(id: params[:system_ids])
        selected_subsystems = Subsystem.where(id: params[:subsystem_ids])
      
        ActiveRecord::Base.transaction do
          supplier.projects = selected_projects
          supplier.project_scopes = selected_scopes
          supplier.systems = selected_systems
          supplier.subsystems = selected_subsystems
          supplier.update!(status: "approved")
      
          notification.update!(status: "resolved")
        end
      
        render json: { message: "Supplier approved successfully" }
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
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
          :supplier_name, :supplier_category, :total_years_in_saudi_market,
          :phone, :supplier_email, :password, :password_confirmation,
          :registration_type, :purpose, :evaluation_type,
          {  projects: [], project_scopes: [], systems: [], subsystems: [] } # Ensure arrays are permitted
        )
      end
      
      
    end
  end
end
