class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    if params[:supplier_id].present?
      stream_from "notifications_#{params[:supplier_id]}_channel"
    else
      stream_from "notifications_channel"
    end
  end

  def unsubscribed
    # Any cleanup when channel is unsubscribed
  end
end
