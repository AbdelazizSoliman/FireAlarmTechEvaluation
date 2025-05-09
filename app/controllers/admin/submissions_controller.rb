# app/controllers/admin/submissions_controller.rb
 class Admin::SubmissionsController < ApplicationController
  def index
    @notifications = Notification
      .where(notification_type: 'evaluation')
      .order(created_at: :desc)
      .includes(:notifiable)
  end

  def show
    @notification = Notification.find(params[:id])
    @payload      = JSON.parse(@notification.additional_data || "{}")
  end
end
