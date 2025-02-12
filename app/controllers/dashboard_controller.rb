class DashboardController < ApplicationController
  before_action :authenticate_user! # Ensures only logged-in users can access

  def index
    @notifications = Notification.where(read: false).order(created_at: :desc)
  end
end
