class SubsystemsController < ApplicationController
  def index
    @subsystems = Subsystem.all.includes(:system, system: :project_scope)
  end

  def new
    @subsystem = Subsystem.new
    @projects = Project.all # Load all projects for the dropdown
  end

  def create
    @subsystem = Subsystem.new(subsystem_params)
    if @subsystem.save
      redirect_to subsystems_path, notice: 'Subsystem created successfully.'
    else
      @projects = Project.all # Reload projects if validation fails
      render :new
    end
  end

  def show
    @subsystem = Subsystem.find(params[:id])
  end

  private

  def subsystem_params
    params.require(:subsystem).permit(:name, :system_id)
  end
end