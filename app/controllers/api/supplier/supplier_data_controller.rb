module Api
  module Supplier
    class SupplierDataController < Api::ApplicationController
      before_action :authenticate_supplier!

      def index
        render json: {
          supplier_name: current_supplier.supplier_name,
          supplier_category: current_supplier.supplier_category,
          total_years_in_saudi_market: current_supplier.total_years_in_saudi_market
        }, status: :ok
      end
    end
  end
end
