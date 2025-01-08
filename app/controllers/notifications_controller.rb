class NotificationsController < ApplicationController
  before_action :set_notification, only: [:approve, :reject]

  def approve
    supplier = @notification.notifiable
    if supplier
      supplier.update!(status: 'approved')
    end
    @notification.update!(read: true, status: 'approved')

    redirect_back fallback_location: suppliers_path, notice: 'Supplier approved.'
  end

  def reject
    supplier = @notification.notifiable
    if supplier
      supplier.update!(status: 'rejected')
    end
    @notification.update!(read: true, status: 'rejected')

    redirect_back fallback_location: suppliers_path, notice: 'Supplier rejected.'
  end

  private

  def set_notification
    @notification = Notification.find(params[:id])
  end
end
