class SystemsController < ApplicationController
    def show
      @project = Project.find(params[:project_id])
      @system = @project.systems.find(params[:id])
      @subsystems = @system.subsystems
    end
  end
  