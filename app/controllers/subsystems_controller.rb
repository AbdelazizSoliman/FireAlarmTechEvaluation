class SubsystemsController < ApplicationController
  before_action :set_nested_resources, only: [:index, :show, :assign, :assign_supplier]

  def index
    @subsystems = if @system.present?
                    @system.subsystems
                  else
                    Subsystem.all
                  end
  end

  def show
    @subsystem = Subsystem.find(params[:id])
  end

  def assign
    @subsystem = Subsystem.find(params[:id])
    @suppliers = Supplier.where(status: "approved")
  end

  def assign_supplier
    @subsystem = Subsystem.find(params[:id])
    supplier = Supplier.find(params[:supplier_id])
    SubsystemSupplier.create!(subsystem: @subsystem, supplier: supplier)

    # Create notification for supplier
    Notification.create!(
      title: "New Project Assigned",
      body: "Project #{@subsystem.system.project.name} - #{@subsystem.system.name} #{@subsystem.name} was assigned to you. Please submit your data for evaluation.",
      notifiable: supplier,
      read: false,
      status: "pending"
    )

    redirect_to subsystem_path(@subsystem), notice: "Assigned #{@subsystem.name} to #{supplier.supplier_name}."
  end

  private

  def set_nested_resources
    @project = Project.find(params[:project_id]) if params[:project_id]
    @system = System.find(params[:system_id]) if params[:system_id]
  end
end
