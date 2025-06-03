# supplier_api/app/controllers/api/supplier/supplier_data_controller.rb
module Api
  module Supplier
    class SupplierDataController < Api::ApplicationController
      def index
        supplier = current_supplier
        if supplier
          render json: {
            supplier_name: supplier.supplier_name,
            supplier_category: supplier.supplier_category,
            total_years_in_saudi_market: supplier.total_years_in_saudi_market
          }, status: :ok
        else
          render json: { error: "Supplier not found" }, status: :not_found
        end
      end
    end
  end
end
