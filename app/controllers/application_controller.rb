class ApplicationController < ActionController::Base
    before_action :configure_permitted_parameters, if: :devise_controller?
    protect_from_forgery with: :exception, unless: -> { request.format.json? }
  
    before_action :set_cors_headers
    # before_action :authenticate_user!
    before_action :set_unread_notifications_count
    helper_method :current_supplier

  
    protected
    # protect all routes by default and allow some extra params:
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name terms_and_conditions])
      devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name])
    end

    def after_sign_out_path_for(_resource_or_scope)
      new_user_session_path # Redirect to the login page
    end

    def current_supplier
      header = request.headers['Authorization']
      token = header.split(' ').last if header
      decoded = JsonWebToken.decode(token) rescue nil
      @current_supplier ||= Supplier.find_by(id: decoded[:supplier_id]) if decoded
    end
    
    # def current_supplier
    #   Rails.logger.info "Session supplier_id: #{session[:supplier_id]}"
    #   @current_supplier ||= Supplier.find_by(id: session[:supplier_id])
    # end
    
    
    private

    def set_cors_headers
      response.set_header('Access-Control-Allow-Origin', 'http://localhost:5173') # Frontend origin
      response.set_header('Access-Control-Allow-Credentials', 'true')
    end

    def set_unread_notifications_count
      if current_user
        Rails.logger.info "Current User: #{current_user.full_name}"
        @unread_notifications_count = Notification.where(read: false).count
      else
        @unread_notifications_count = 0
      end
    end
end
  
  