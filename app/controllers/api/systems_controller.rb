module Api
  class SystemsController < Api::ApplicationController
    def index
      systems = System.where(project_scope_id: params[:project_scope_id])
      render json: systems
    end
  end
end
