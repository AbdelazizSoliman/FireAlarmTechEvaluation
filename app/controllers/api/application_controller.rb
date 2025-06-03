module Api
  class ApplicationController < ActionController::API
    # JWT Auth Helper
    protected

    def authenticate_supplier!
      auth_header = request.headers['Authorization']
      unless auth_header&.start_with?('Bearer ')
        render json: { error: 'Unauthorized (missing or malformed token)' }, status: :unauthorized and return
      end
      token = auth_header.split(' ').last
      begin
        decoded = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS256' })
        supplier_id = decoded[0]['sub']
        @current_supplier = ::Supplier.find_by(id: supplier_id)
        render json: { error: 'Unauthorized (supplier not found)' }, status: :unauthorized and return unless @current_supplier
      rescue JWT::DecodeError
        render json: { error: 'Invalid token' }, status: :unauthorized and return
      end
    end

    def current_supplier
      @current_supplier
    end
  end
end
