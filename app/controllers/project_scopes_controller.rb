class ProjectScopesController < ApplicationController
  before_action :set_project, only: [:index, :new, :create]

  def index
    if @project
      @project_scopes = @project.project_scopes
    else
      @project_scopes = ProjectScope.all
    end
    respond_to do |format|
      format.html
      format.json { render json: @project_scopes }
    end
  end

  def new
    @project_scope = ProjectScope.new
    @projects = Project.all # For standalone creation
  end

  def create
    if @project
      @project_scope = @project.project_scopes.build(project_scope_params)
    else
      @project_scope = ProjectScope.new(project_scope_params)
    end
    if @project_scope.save
      redirect_to project_path(@project || @project_scope.project), notice: 'Project scope created successfully.'
    else
      render :new
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id]) if params[:project_id].present?
  end

  def project_scope_params
    params.require(:project_scope).permit(:name, :project_id)
  end
end