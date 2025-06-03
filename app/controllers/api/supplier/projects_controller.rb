module Api
  module Supplier
    class ProjectsController < Api::ApplicationController
      def index
        projects = Project.all
        render json: projects
      end
    end
  end
end
