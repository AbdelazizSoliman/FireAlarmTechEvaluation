# app/controllers/admin/submissions_controller.rb
class Admin::SubmissionsController < Admin::BaseController
  def index
    @notifications = Notification
      .where(notification_type: 'submission')
      .order(created_at: :desc)
      .includes(:notifiable)
  end

  def show
    @notification = Notification.find(params[:id])
    @payload      = JSON.parse(@notification.additional_data || "{}")
  end
end
