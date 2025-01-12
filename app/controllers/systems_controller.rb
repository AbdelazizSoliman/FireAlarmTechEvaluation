class SystemsController < ApplicationController
  before_action :set_project_scope, only: [:new, :create]

   def index
  @project_scope = ProjectScope.find(params[:project_scope_id])
  @systems = @project_scope.systems
end

def show
  @system = System.find(params[:id])
  @subsystems = @system.subsystems
end

def new
  @system = System.new
end

def create
  @system = @project_scope.systems.new(system_params)
  if @system.save
    redirect_to project_scope_path(@project_scope), notice: "System created successfully."
  else
    render :new
  end
end

  private

  def set_project_scope
    @project_scope = ProjectScope.find(params[:project_scope_id])
  end

  def system_params
    params.require(:system).permit(:name)
  end

end
