class PagesController < ApplicationController

  before_action :set_project 
  
  def index
    @notifications = Notification.where(read: false).order(created_at: :desc)
  end
  

  private

  def set_project
    if params[:project_id]
      @project = Project.find(params[:project_id])
    end
  end
end
