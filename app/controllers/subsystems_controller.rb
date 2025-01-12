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
    # @projects = Project.all
  end

  def create
    @subsystem = Subsystem.new(subsystem_params)
    if @subsystem.save
      redirect_to project_scope_system_path(@system.project_scope, @system), notice: "Subsystem created successfully."
    else
      flash[:alert] = "Error creating subsystem: " + @subsystem.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end


  private

  def set_nested_resources
   
    @system = System.find(params[:system_id]) if params[:system_id]
  end

  def set_subsystem
    @subsystem = Subsystem.find(params[:id])
  end

  def subsystem_params
    params.require(:subsystem).permit(:name, :system_id)
  end
end
