module Api
    module Supplier
      class SessionsController < ApplicationController
        skip_before_action :verify_authenticity_token

      def create
  email = params[:email] || params.dig(:session, :email)
  password = params[:password] || params.dig(:session, :password)
  Rails.logger.info("Login attempt with email: #{email}")

  supplier = ::Supplier.where('LOWER(supplier_email) = ?', email.to_s.downcase).first
  if supplier&.authenticate(password)
    Rails.logger.info("Supplier found: #{supplier.id}, status: #{supplier.status}")
    session[:supplier_id] = supplier.id
    token = generate_token(supplier.id)
    render json: { token: token, status: supplier.status, supplier_id: supplier.id }, status: :ok
  else
    Rails.logger.info("No supplier found or invalid password for email: #{email}")
    render json: { error: 'Invalid email or password' }, status: :unauthorized
  end
end


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

        def generate_token(supplier_id)
          payload = {
            sub: supplier_id,
            exp: 24.hours.from_now.to_i
          }
          JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
        end

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