module Api
  module Supplier
    class SuppliersController < ApplicationController
      skip_before_action :verify_authenticity_token

      before_action :set_supplier, only: %i[show edit update destroy]

      def mark_all_read
        Notification.update_all(read: true)
        render json: { message: "All notifications marked as read" }, status: :ok
      end
      

      def assign_membership
        @supplier = ::Supplier.find(params[:id])
      
        @supplier.update!(
          membership_type: params[:membership_type],
          receive_evaluation_report: params[:receive_evaluation_report]
        )
      
        if params[:membership_type] == "gold"
          @supplier.projects = Project.where(id: params[:project_ids])
        elsif params[:membership_type] == "silver"
          @supplier.subsystems = Subsystem.where(id: params[:subsystem_ids])
        end
      
        Notification.create!(
          title: "Membership Assigned",
          body: "You have been assigned #{params[:membership_type].capitalize} Membership.",
          notifiable: @supplier,
          read: false,
          status: "active"
        )
      
        render json: { message: "Membership assigned successfully" }, status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
      
      def register
        @supplier = ::Supplier.new(supplier_params)
        if @supplier.save
          Notification.create!(
            title: "New Supplier Registration",
            body: "Supplier #{@supplier.supplier_name} has registered.",
            notifiable: @supplier,
            read: false,
            status: "pending"
          )
          render json: { message: 'Supplier registered successfully' }, status: :created
        else
          render json: { errors: @supplier.errors.full_messages }, status: :unprocessable_entity
        end
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

      # DELETE /suppliers/1
      def destroy
        @supplier.destroy!
        redirect_to suppliers_url, notice: "Supplier was successfully destroyed.", status: :see_other
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_supplier
        @supplier = ::Supplier.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def supplier_params
        params.require(:supplier).permit(
          :supplier_name,
          :supplier_category,
          :total_years_in_saudi_market,
          :phone,
          :supplier_email,
          :password,
          :password_confirmation,
           :status,# Allow status updates
          :membership_type,
    :receive_evaluation_report
        )
      end
    end
  end
end
