class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notifications_#{params[:supplier_id]}_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
