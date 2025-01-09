module Api
    class NotificationsController < ApplicationController
      def index
        @notifications = Notification.where(read: false).order(created_at: :desc)
        render json: @notifications
      end
  
      def update
        notification = Notification.find(params[:id])
        notification.update!(read: true)
        render json: { success: true }
      end
    end
  end
  