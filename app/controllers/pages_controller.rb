class PagesController < ApplicationController
  def index
    @notifications = Notification.where(read: false).order(created_at: :desc)
  end
  

  def settings
  end

  def disposal_cost

  end
end
