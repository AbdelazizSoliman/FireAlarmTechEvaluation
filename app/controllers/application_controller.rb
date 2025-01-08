class ApplicationController < ActionController::Base
    before_action :configure_permitted_parameters, if: :devise_controller?
    # before_action :authenticate_user!
    before_action :set_unread_notifications_count

  
    protected
    # protect all routes by default and allow some extra params:
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name terms_and_conditions])
      devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name])
    end


    private

    def set_unread_notifications_count
      if current_user
        Rails.logger.info "Current User: #{current_user.full_name}"
        @unread_notifications_count = Notification.where(read: false).count
      else
        Rails.logger.info "No user is currently logged in."
      end
    end
end
  
  