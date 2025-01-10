class SubsystemsController < ApplicationController
  before_action :set_nested_resources, only: [:index, :show, :new, :create, :assign, :assign_supplier]
  before_action :set_subsystem, only: [:show, :assign, :assign_supplier]

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

  def new
    @subsystem = Subsystem.new
    @projects = Project.all
  end

  def create
    @subsystem = Subsystem.new(subsystem_params)
    if @subsystem.save
      redirect_to subsystems_path, notice: "Subsystem created successfully."
    else
      flash[:alert] = "Error creating subsystem: " + @subsystem.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def assign
    @suppliers = Supplier.where(status: "approved")
  end

  def assign_supplier
    supplier = Supplier.find(params[:supplier_id])
    SubsystemSupplier.create!(subsystem: @subsystem, supplier: supplier)
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

  def set_subsystem
    @subsystem = Subsystem.find(params[:id])
  end

  def subsystem_params
    params.require(:subsystem).permit(:name, :system_id)
  end
end
