# app/controllers/api/application_controller.rb
module Api
  class ApplicationController < ActionController::API
    # Use this as your base for all API controllers

    # If you want to secure all API endpoints by default:
    # before_action :authenticate_supplier!
    # Add skip_before_action :authenticate_supplier! to login/register controllers

    # Handle CORS preflight for API (if not done by Rack Middleware)
    before_action :set_cors_headers

    # Optionally force all responses to JSON
    before_action :force_json

    def force_json
      request.format = :json
    end

    private

    def set_cors_headers
      headers['Access-Control-Allow-Origin'] = '*' # Or set to specific domain
      headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD'
      headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization'
      headers['Access-Control-Allow-Credentials'] = 'true'
    end

    # Your JWT authenticate_supplier! can be included here or as a concern if you want
    # Otherwise, add it to controllers that need it
  end
end
