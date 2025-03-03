# app/controllers/api/supplier/sessions_controller.rb
module Api
  module Supplier
    class SessionsController < ApplicationController
      skip_before_action :verify_authenticity_token

      # Login action
      def create
        supplier = ::Supplier.find_by(supplier_email: params[:email])
        if supplier&.authenticate(params[:password])
          session[:supplier_id] = supplier.id
          token = generate_token(supplier.id)
          render json: { token: token, status: supplier.status, supplier_id: supplier.id }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      # Profile action
      def profile
        supplier = authenticate_supplier!
        if supplier
          render json: {
            id: supplier.id,
            supplier_name: supplier.supplier_name,
            supplier_category: supplier.supplier_category,
            supplier_evaluation_type: supplier.evaluation_type,
            supplier_email: supplier.supplier_email,
            phone: supplier.phone,
            total_years_in_saudi_market: supplier.total_years_in_saudi_market,
            status: supplier.status
          }, status: :ok
        else
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      private

      # Generate a JWT token
      def generate_token(supplier_id)
        payload = {
          sub: supplier_id, # Use 'sub' to store the subject (supplier ID)
          exp: 24.hours.from_now.to_i # Token expiration (24 hours)
        }
        JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
      end

      # Authenticate supplier via token
      def authenticate_supplier!
        auth_header = request.headers['Authorization']
        return unless auth_header&.starts_with?('Bearer ')

        token = auth_header.split(' ').last
        begin
          decoded = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS256' })
          payload = decoded.first
          supplier_id = payload['sub']
          ::Supplier.find_by(id: supplier_id)
        rescue JWT::DecodeError
          nil
        end
      end
    end
  end
end
