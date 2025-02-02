module Api
  module Supplier
    class SuppliersController < ApplicationController
      skip_before_action :verify_authenticity_token

      # ✅ Supplier Registration
      def register
        Rails.logger.info "Received registration params: #{params.inspect}"

        supplier = ::Supplier.new(supplier_params.except(:projects, :project_scopes, :systems, :subsystems))

        ActiveRecord::Base.transaction do
          if supplier.save
            # ✅ Assign related entities if present
            supplier.projects = Project.where(id: params[:supplier][:projects]) if params[:supplier][:projects].present?
            supplier.project_scopes = ProjectScope.where(id: params[:supplier][:project_scopes]) if params[:supplier][:project_scopes].present?
            supplier.systems = System.where(id: params[:supplier][:systems]) if params[:supplier][:systems].present?
            supplier.subsystems = Subsystem.where(id: params[:supplier][:subsystems]) if params[:supplier][:subsystems].present?

            supplier.save!

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
            Rails.logger.error "Registration failed: #{supplier.errors.full_messages}"
            render json: { errors: supplier.errors.full_messages }, status: :unprocessable_entity
          end
        end
      rescue StandardError => e
        Rails.logger.error "Error in supplier registration: #{e.message}"
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # ✅ Approve Supplier
      def approve_supplier
        @notification = Notification.find(params[:id])
        @supplier = @notification.notifiable

        ActiveRecord::Base.transaction do
          # ✅ Update supplier status
          @supplier.update!(
            receive_evaluation_report: params[:receive_evaluation_report] == "true",
            status: "approved"
          )

          # ✅ Approve associated entities in join tables
          if params[:project_ids].present?
            @supplier.projects_suppliers.where(project_id: params[:project_ids]).update_all(approved: true)
          end
          if params[:project_scope_ids].present?
            @supplier.project_scopes_suppliers.where(project_scope_id: params[:project_scope_ids]).update_all(approved: true)
          end
          if params[:system_ids].present?
            @supplier.systems_suppliers.where(system_id: params[:system_ids]).update_all(approved: true)
          end
          if params[:subsystem_ids].present?
            @supplier.subsystems_suppliers.where(subsystem_id: params[:subsystem_ids]).update_all(approved: true)
          end

          # ✅ Mark notification as resolved
          @notification.update!(status: "resolved")
        end

        redirect_to notifications_path, notice: "Supplier approved successfully."
      rescue => e
        redirect_to manage_membership_notification_path(@notification, supplier_id: @supplier.id),
                    alert: "Error: #{e.message}"
      end

      # ✅ Reject Supplier
      def reject_supplier
        notification = Notification.find(params[:id])
        supplier = notification.notifiable

        ActiveRecord::Base.transaction do
          supplier.update!(status: "rejected")
          notification.update!(status: "resolved")
        end

        render json: { message: "Supplier rejected successfully" }
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # ✅ Supplier Dashboard
      def dashboard
        supplier = ::Supplier.find(params[:supplier_id])  # 🔥 Explicitly reference Supplier model
      
        projects = supplier.projects
                            .joins(:projects_suppliers)
                            .where(projects_suppliers: { approved: true })
                            .distinct
                            .map do |project|
          {
            id: project.id,
            name: project.name,
            project_scopes: project.project_scopes
                                   .joins("INNER JOIN project_scopes_suppliers ON project_scopes.id = project_scopes_suppliers.project_scope_id")
                                   .where("project_scopes_suppliers.supplier_id = ? AND project_scopes_suppliers.approved = ?", supplier.id, true)
                                   .distinct
                                   .map do |scope|
              {
                id: scope.id,
                name: scope.name,
                systems: scope.systems
                               .joins("INNER JOIN systems_suppliers ON systems.id = systems_suppliers.system_id")
                               .where("systems_suppliers.supplier_id = ? AND systems_suppliers.approved = ?", supplier.id, true)
                               .distinct
                               .map do |system|
                  {
                    id: system.id,
                    name: system.name,
                    subsystems: system.subsystems
                                       .joins("INNER JOIN subsystems_suppliers ON subsystems.id = subsystems_suppliers.subsystem_id")
                                       .where("subsystems_suppliers.supplier_id = ? AND subsystems_suppliers.approved = ?", supplier.id, true)
                                       .distinct
                                       .map { |subsystem| { id: subsystem.id, name: subsystem.name } }
                  }
                end
              }
            end
          }
        end
      
        render json: { projects: projects }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Supplier not found" }, status: :not_found
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
