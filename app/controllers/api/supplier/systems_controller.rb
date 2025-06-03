module Api
  module Supplier
    class SystemsController < Api::ApplicationController
      def index
        if params[:project_scope_ids].present?
          project_scope_ids = params[:project_scope_ids].map(&:to_i)
          systems = System.where(project_scope_id: project_scope_ids)
        else
          systems = System.all
        end
        render json: systems
      end
    end
  end
end
