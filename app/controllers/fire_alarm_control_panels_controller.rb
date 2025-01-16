class NotificationsController < ApplicationController
  def index
    @notifications = Notification.all.order(created_at: :desc)
  end

  def show
    @notification = Notification.find(params[:id])
    @fire_alarm_control_panel = @notification.notifiable if @notification.notifiable_type == "FireAlarmControlPanel"
  end
end
