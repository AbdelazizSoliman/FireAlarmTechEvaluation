class SubsystemsController < ApplicationController
  # before_action :set_nested_resources, only: [:index, :show, :new, :create, :assign, :assign_supplier]
  before_action :set_system

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
    @subsystem = @system.subsystems.new
  end

  def create
    @subsystem = @system.subsystems.new(subsystem_params)
    if @subsystem.save
      redirect_to @system.project_scope.project, notice: 'Subsystem was successfully created.'
    else
      render :new
    end
  end


  private

  def set_nested_resources
   
    @system = System.find(params[:system_id]) if params[:system_id]
  end

  def set_system
    @system = System.find(params[:system_id])
  end

  def subsystem_params
    params.require(:subsystem).permit(:name)
  end
end
