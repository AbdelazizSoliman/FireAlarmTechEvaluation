class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :exception, unless: -> { request.format.json? }

  before_action :set_cors_headers
  before_action :authenticate_user!           # Uncomment if you want to require login for all pages
  before_action :set_unread_notifications     # Load unread notifications globally
  helper_method :current_supplier

  protected

  # Permit additional Devise parameters
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name terms_and_conditions])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name])
  end

  # Redirect after logout
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  # Example of a helper method for a custom supplier session
  def current_supplier
    @current_supplier ||= Supplier.find_by(id: session[:supplier_id])
  end

  private

  # Optional: set CORS headers if needed
  def set_cors_headers
    # response.set_header('Access-Control-Allow-Origin', 'http://localhost:5173')
    # response.set_header('Access-Control-Allow-Credentials', 'true')
  end

  # Loads all unread notifications (or user-specific if you have such logic)
  def set_unread_notifications
  if current_user
    Rails.logger.info "Current User: #{current_user.full_name}"
    @notifications = Notification.where(notifiable: current_user, read: false).order(created_at: :desc)
    @unread_notifications_count = @notifications.count
  elsif current_supplier
    Rails.logger.info "Current Supplier: #{current_supplier.supplier_name}"
    @notifications = Notification.where(notifiable: current_supplier, read: false).order(created_at: :desc)
    @unread_notifications_count = @notifications.count
  else
    @notifications = []
    @unread_notifications_count = 0
  end
end

end
