class ProjectScopesController < ApplicationController
    before_action :set_project
    before_action :set_project_scope
  
    def index
      @project_scopes = @project.project_scopes
    end
    
  
    def show
      @project = Project.find(params[:project_id])
  @project_scope = @project.project_scopes.find(params[:id])
    end
  
    def new
      @project_scope = @project.project_scopes.new
    end
  
    def create
      @project_scope = @project.project_scopes.new(project_scope_params)
      if @project_scope.save
        redirect_to @project, notice: 'Project Scope was successfully created.'
      else
        render :new
      end
    end
  
    private
  
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_project_scope
      @project_scope = @project.project_scopes.find(params[:id])
    end
  
    def project_scope_params
      params.require(:project_scope).permit(:name)
    end

  end
  