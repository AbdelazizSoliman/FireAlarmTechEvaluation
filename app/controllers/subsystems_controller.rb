class SubsystemsController < ApplicationController
    def show
      @system = System.find(params[:system_id])
      @subsystem = @system.subsystems.find(params[:id])
    end
  end
  