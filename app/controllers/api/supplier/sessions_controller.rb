module Api
  module Supplier
    class SessionsController < Api::ApplicationController
      # POST /api/supplier/login
      def create
        email = params[:email].to_s.downcase
        password = params[:password]

        supplier = ::Supplier.find_by('LOWER(supplier_email) = ?', email)
        if supplier&.authenticate(password)
          token = JWT.encode({ sub: supplier.id, exp: 24.hours.from_now.to_i }, Rails.application.secret_key_base, 'HS256')
          render json: { token: token, status: supplier.status, supplier_id: supplier.id }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      # GET /api/supplier/profile
      def profile
        authenticate_supplier!
        if current_supplier
          render json: {
            id: current_supplier.id,
            supplier_name: current_supplier.supplier_name,
            supplier_category: current_supplier.supplier_category,
            supplier_evaluation_type: current_supplier.evaluation_type,
            supplier_email: current_supplier.supplier_email,
            phone: current_supplier.phone,
            total_years_in_saudi_market: current_supplier.total_years_in_saudi_market,
            status: current_supplier.status
          }, status: :ok
        else
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end
    end
  end
end
