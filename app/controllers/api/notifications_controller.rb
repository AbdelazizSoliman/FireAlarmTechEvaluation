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
      if params[:membership_type].blank? || params[:receive_evaluation_report].nil?
        render json: { error: "Please select all required fields." }, status: :unprocessable_entity
        return
      end

      ActiveRecord::Base.transaction do
        @supplier.update!(
          membership_type: params[:membership_type],
          receive_evaluation_report: params[:receive_evaluation_report] == "true",
          status: "approved"
        )

        if params[:membership_type] == "gold"
          @supplier.projects = Project.where(id: params[:project_ids] || [])
        elsif params[:membership_type] == "silver"
          @supplier.subsystems = Subsystem.where(id: params[:subsystem_ids] || [])
        end

        @notification.update!(read: true, status: "resolved")
      end

      render json: { message: "#{@supplier.supplier_name} approved with #{params[:membership_type].capitalize} membership." }, status: :ok
    rescue => e
      Rails.logger.error "Error approving supplier: #{e.message}"
      render json: { error: e.message }, status: :unprocessable_entity
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
