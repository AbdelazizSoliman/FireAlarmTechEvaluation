class SystemsController < ApplicationController
  def index
    @systems = System.all.includes(:subsystems) # Preload subsystems for efficiency
  end

  def show
    @system = System.find(params[:id])
    @subsystems = @system.subsystems
  end
end
