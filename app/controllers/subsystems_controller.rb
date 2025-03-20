class SubsystemsController < ApplicationController
  before_action :set_project, :set_project_scope, :set_system, only: [:new, :create]

  def index
    @subsystems = Subsystem.all.includes(:system, system: :project_scope)
  end

  def new
    @subsystem = Subsystem.new
    if @system && @project_scope && @project
      @systems = @project_scope.systems # Load systems for the selected scope
    else
      redirect_to new_system_path, alert: 'Please select a project, project scope, and system first.'
    end
  end

  def create
    @subsystem = @system.subsystems.build(subsystem_params)
    if @subsystem.save
      redirect_to project_project_scope_system_path(@project, @project_scope, @system), notice: 'Subsystem created successfully.'
    else
      @systems = @project_scope.systems if @project_scope
      render :new
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id]) if params[:project_id].present?
    redirect_to projects_path, alert: 'Project not found or not specified.' unless @project
  rescue ActiveRecord::RecordNotFound
    redirect_to projects_path, alert: 'Project not found.'
  end

  def set_project_scope
    return unless @project
    @project_scope = ProjectScope.find(params[:project_scope_id]) if params[:project_scope_id].present?
    redirect_to project_path(@project), alert: 'Project scope not found or not specified.' unless @project_scope
  rescue ActiveRecord::RecordNotFound
    redirect_to project_path(@project), alert: 'Project scope not found.'
  end

  def set_system
    return unless @project_scope
    @system = System.find(params[:system_id]) if params[:system_id].present?
    redirect_to project_project_scope_path(@project, @project_scope), alert: 'System not found or not specified.' unless @system
  rescue ActiveRecord::RecordNotFound
    redirect_to project_project_scope_path(@project, @project_scope), alert: 'System not found.'
  end

  def subsystem_params
    params.require(:subsystem).permit(:name)
  end
end