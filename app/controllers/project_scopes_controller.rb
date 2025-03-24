class ProjectScopesController < ApplicationController
  before_action :set_project_scope, only: [:show]

  def index
    project_scopes = params[:project_id].present? ? Project.find(params[:project_id]).project_scopes : ProjectScope.all
    respond_to do |format|
      format.json { render json: project_scopes }
    end
  end

  def show
    @project_scope = ProjectScope.includes(:systems).find(params[:id])
  end

  def new
    @project_scope = ProjectScope.new
    @projects = Project.all
  end

  def create
    if params[:project_id].present?
      @project = Project.find(params[:project_id])
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

  def set_project_scope
    @project_scope = ProjectScope.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to project_scopes_path, alert: 'Project scope not found.'
  end

  def project_scope_params
    params.require(:project_scope).permit(:name, :project_id)
  end
end