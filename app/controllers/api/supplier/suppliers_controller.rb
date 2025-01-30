module Api
  module Supplier
    class SuppliersController < ApplicationController
      skip_before_action :verify_authenticity_token

      before_action :set_supplier, only: %i[show edit update]

      def mark_all_read
        Notification.update_all(read: true)
        render json: { message: "All notifications marked as read" }, status: :ok
      end

      def profile
        supplier = ::Supplier.find_by(id: params[:supplier_id])

        if supplier.nil?
          render json: { error: "Supplier not found" }, status: :not_found
          return
        end

        render json: {
          id: supplier.id,
          supplier_name: supplier.supplier_name,
          supplier_email: supplier.supplier_email,
          supplier_category: supplier.supplier_category,
          phone: supplier.phone,
          total_years_in_saudi_market: supplier.total_years_in_saudi_market,
          status: supplier.status,
          membership_type: supplier.membership_type,
          projects: supplier.membership_type == "projects" ? supplier.projects.map { |project| { id: project.id, name: project.name } } : [],
          subsystems: supplier.membership_type == "systems" ? supplier.subsystems.map { |subsystem| { id: subsystem.id, name: subsystem.name, system_id: subsystem.system_id } } : [],
        }
      end

      def assign_membership
        @supplier = ::Supplier.find(params[:id])

        @supplier.update!(
          membership_type: params[:membership_type],
          receive_evaluation_report: params[:receive_evaluation_report],
        )

        if params[:membership_type] == "projects"
          @supplier.projects = Project.where(id: params[:project_ids])
        elsif params[:membership_type] == "systems"
          @supplier.subsystems = Subsystem.where(id: params[:subsystem_ids])
        end

        Notification.create!(
          title: "Membership Assigned",
          body: "You have been assigned #{params[:membership_type].capitalize} Membership.",
          notifiable: @supplier,
          read: false,
          status: "active",
          notification_type: "membership",
        )

        render json: { message: "Membership assigned successfully" }, status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def register
        supplier_params_with_subsystems = supplier_params.dup
      
        # Map subsystem names to Subsystem objects
        if supplier_params[:subsystems].present?
          subsystem_objects = Subsystem.where(name: supplier_params[:subsystems])
          supplier_params_with_subsystems[:subsystems] = subsystem_objects
        end
      
        # Create the supplier
        supplier = ::Supplier.new(supplier_params_with_subsystems)
      
        if supplier.save
          render json: { message: "Supplier registered successfully" }, status: :created
        else
          render json: { errors: supplier.errors.full_messages }, status: :unprocessable_entity
        end
      rescue => e
        Rails.logger.error "Error in supplier registration: #{e.message}"
        render json: { error: "An error occurred: #{e.message}" }, status: :internal_server_error
      end
      
      

      # GET /suppliers
      def index
        @suppliers = ::Supplier.all.order(:created_at)
        respond_to do |format|
          format.html # renders the HTML view (default)
          format.json { render json: @suppliers } # renders JSON response
        end
      end

      # GET /suppliers/1
      def show
      end

      # GET /suppliers/new
      def new
        @supplier = ::Supplier.new
      end

      # GET /suppliers/1/edit
      def edit
      end

      # POST /suppliers
      def create
        @supplier = ::Supplier.new(supplier_params)

        if @supplier.save
          redirect_to @supplier, notice: "Supplier was successfully created."
        else
          render :new, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /suppliers/1
      def update
        if @supplier.update(supplier_params)
          redirect_to @supplier, notice: "Supplier was successfully updated.", status: :see_other
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def dashboard
        supplier = ::Supplier.find_by(id: params[:supplier_id])

        if supplier.nil?
          render json: { error: "Supplier not found" }, status: :not_found
          return
        end

        render json: {
          id: supplier.id,
          supplier_name: supplier.supplier_name,
          membership_type: supplier.membership_type,
          projects: supplier.membership_type == "projects" ? supplier.projects.select(:id, :name) : [],
          subsystems: supplier.membership_type == "systems" ? supplier.subsystems.select(:id, :name, :system_id) : [],
        }
      end

      def approve_supplier
        Rails.logger.info "Params received: #{params.inspect}"

        if params[:supplier_id].blank?
          redirect_to manage_membership_notification_path(@notification), alert: "Supplier ID is missing."
          return
        end

        @supplier = Supplier.find(params[:supplier_id])

        # Only enforce evaluation-related fields if the supplier registered for evaluation
        if @supplier.registration_type == "evaluation"
          if params[:membership_type].blank? || params[:receive_evaluation_report].blank?
            redirect_to manage_membership_notification_path(@notification, supplier_id: @supplier.id),
                        alert: "Please select all required fields."
            return
          end
        end

        ActiveRecord::Base.transaction do
          # Assign membership type and evaluation report status only for evaluation type
          if @supplier.registration_type == "evaluation"
            @supplier.update!(
              membership_type: params[:membership_type],
              receive_evaluation_report: params[:receive_evaluation_report] == "true",
              status: "approved",
            )

            if params[:membership_type] == "projects"
              selected_projects = params[:project_ids] || []
              @supplier.projects = Project.where(id: selected_projects)
            elsif params[:membership_type] == "systems"
              selected_subsystems = params[:subsystem_ids] || []
              @supplier.subsystems = Subsystem.where(id: selected_subsystems)
            end
          else
            # If Partnership, just update status
            @supplier.update!(status: "approved")
          end

          # Resolve the notification
          @notification.update!(status: "resolved")
        end

        redirect_to suppliers_path, notice: "#{@supplier.supplier_name} has been approved successfully."
      rescue => e
        Rails.logger.error "Error in approve_supplier: #{e.message}"
        redirect_to manage_membership_notification_path(@notification, supplier_id: @supplier.id), alert: "Error: #{e.message}"
      end

      private

      def set_supplier
        @supplier = ::Supplier.find(params[:id])
      end

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
          subsystems: [], # Allow an array of subsystem selections
        )
      end
    end
  end
end
