class SystemsController < ApplicationController
  before_action :set_project, only: [:new, :create]

  def index
    @projects = Project.all
  @systems = System.all
  end
  
  def show
    @system = System.find(params[:id])
  end

  def new
    @system = System.new
    @projects = Project.all
  end

  def create
    @system = System.new(system_params)
    if @system.save
      redirect_to systems_path, notice: "System created successfully."
    else
      @projects = Project.all
      render :new
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

def system_params
  params.require(:system).permit(:name, :project_id)
end

end
