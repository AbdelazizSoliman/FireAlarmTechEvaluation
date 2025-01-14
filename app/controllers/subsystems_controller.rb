class SubsystemsController < ApplicationController
  before_action :set_project
  before_action :set_project_scope
  before_action :set_system

  def index
    @systems = @project_scope.systems
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
     redirect_to @project, notice: 'Subsystem was successfully created.'
    else
      render :new
    end
  end


  private

  
  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_project_scope
    @project_scope = @project.project_scopes.find(params[:project_scope_id])
  end

  def set_system
    @system = @project_scope.systems.find(params[:id])
  end

  def subsystem_params
    params.require(:subsystem).permit(:name)
  end
end
