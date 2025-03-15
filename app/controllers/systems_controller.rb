class SystemsController < ApplicationController
  before_action :set_project_scope, only: [:new, :create]

  def index
    if params[:project_scope_id].present?
      @project_scope = ProjectScope.find(params[:project_scope_id])
      @systems = @project_scope.systems
    else
      @systems = System.all
    end
  end

  def new
    @system = System.new
    @project_scopes = ProjectScope.all # Always provide project scopes for selection
  end

  def create
    if @project_scope
      @system = @project_scope.systems.build(system_params)
    else
      @system = System.new(system_params)
    end
    if @system.save
      redirect_to project_scope_path(@project_scope || @system.project_scope), notice: 'System created successfully.'
    else
      @project_scopes = ProjectScope.all # Re-populate for re-rendering
      render :new
    end
  end

  private

  def set_project_scope
    @project_scope = ProjectScope.find(params[:project_scope_id]) if params[:project_scope_id].present?
  end

  def system_params
    params.require(:system).permit(:name, :project_scope_id)
  end
end