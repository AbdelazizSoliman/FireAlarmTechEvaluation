class SystemsController < ApplicationController
  before_action :set_project
  before_action :set_project_scope


  def index
    @project_scope = ProjectScope.find(params[:project_scope_id])
    @systems = @project_scope.systems
  end


def show
  @system = System.find(params[:id])
  @subsystems = @system.subsystems
end

def new
  @system = @project_scope.systems.new
end
 

def create
  @system = @project_scope.systems.new(system_params)
  if @system.save
    redirect_to project_project_scope_systems_path(@project, @project_scope), notice: 'System was successfully created.'
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

  def system_params
    params.require(:system).permit(:name)
  end

end
