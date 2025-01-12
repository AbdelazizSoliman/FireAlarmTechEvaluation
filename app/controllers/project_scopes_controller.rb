class ProjectScopesController < ApplicationController
    before_action :set_project, only: [:index, :new, :create]
  
    def index
      if @project
        @project_scopes = @project.project_scopes
      else
        @project_scopes = ProjectScope.all.includes(:project)
      end
    end
    
  
    def show
      @project_scope = ProjectScope.find(params[:id])
      @systems = @project_scope.systems
    end
  
    def new
      @project_scope = @project.project_scopes.build
    end
  
    def create
      @project_scope = @project.project_scopes.build(project_scope_params)
      if @project_scope.save
        redirect_to project_path(@project), notice: "Project scope created successfully."
      else
        render :new
      end
    end
  
    private
  
    def set_project
        if params[:project_id]
          @project = Project.find(params[:project_id])
        end
      end
  
    def project_scope_params
      params.require(:project_scope).permit(:name)
    end
  end
  