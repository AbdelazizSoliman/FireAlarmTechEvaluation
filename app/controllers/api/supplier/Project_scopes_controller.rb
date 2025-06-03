module Api
  module Supplier
    class ProjectScopesController < Api::ApplicationController
      def index
        if params[:project_ids].present?
          project_ids = params[:project_ids].map(&:to_i)
          project_scopes = ProjectScope.where(project_id: project_ids)
        else
          project_scopes = ProjectScope.all
        end
        render json: project_scopes
      end
    end
  end
end
