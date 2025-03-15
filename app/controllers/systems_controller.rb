class SystemsController < ApplicationController
  def new
    @system = System.new
    @projects = Project.all # Load all projects for the dropdown
  end

  def create
    @system = System.new(system_params)
    if @system.save
      redirect_to project_path(@system.project_scope.project), notice: 'System created successfully.'
    else
      @projects = Project.all # Reload projects if validation fails
      render :new
    end
  end

  private

  def system_params
    params.require(:system).permit(:name, :project_scope_id)
  end
end