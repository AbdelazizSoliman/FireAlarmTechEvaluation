class ProjectsController < ApplicationController

  def index
    @projects = Project.all.includes(:project_scopes) # Include associated project scopes for better query performance
  end

  def show
    @project = Project.find(params[:id])
    @project_scopes = @project.project_scopes.includes(:systems)
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to projects_path, notice: "Project created successfully."
    else
      render :new
    end
  end

  private

  def project_params
    params.require(:project).permit(:name)
  end
end
