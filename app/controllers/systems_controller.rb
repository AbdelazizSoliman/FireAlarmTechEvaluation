class SystemsController < ApplicationController
  before_action :set_project_scope, only: [:new, :create]

  def index
    if params[:project_scope_id]
      @project_scope = ProjectScope.find(params[:project_scope_id])
      @systems = @project_scope.systems
    else
      @systems = System.all.includes(:project_scope)
    end
  end

  def new
    @system = System.new
    @project_scopes = ProjectScope.all # For standalone creation
  end

  def create
    if params[:project_scope_id]
      @project_scope = ProjectScope.find(params[:project_scope_id])
      @system = @project_scope.systems.new(system_params)
    else
      @system = System.new(system_params)
    end
    if @system.save
      redirect_to project_scope_path(@project_scope || @system.project_scope), notice: "System created successfully."
    else
      render :new
    end
  end

  private

  def set_project_scope
    @project_scope = ProjectScope.find(params[:project_scope_id]) if params[:project_scope_id]
  end

  def system_params
    params.require(:system).permit(:name, :project_scope_id)
  end
end