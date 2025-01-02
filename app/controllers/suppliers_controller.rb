class SuppliersController < ApplicationController
    before_action :set_supplier, only: %i[ show edit update destroy ]

    # GET /suppliers
    def index
      @suppliers = Supplier.all.order(:created_at)
    end
  
    # GET /suppliers/1
    def show
    end
  
    # GET /suppliers/new
    def new
      @supplier = Supplier.new
    end
  
    # GET /suppliers/1/edit
    def edit
    end
  
    # POST /suppliers
    def create
      @supplier = Supplier.new(supplier_params)
  
      if @supplier.save
        redirect_to @supplier, notice: "Supplier was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /suppliers/1
    def update
      if @supplier.update(supplier_params)
        redirect_to @supplier, notice: "Supplier was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end
  
    # DELETE /suppliers/1
    def destroy
        @supplier.destroy!
      redirect_to clients_url, notice: "Supplier was successfully destroyed.", status: :see_other
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_supplier
        @supplier = Supplier.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def supplier_params
        params.require(:supplier).permit(
            :supplier_name,
            :supplier_category,
            :total_years_in_saudi_market,
            :phone,
            :supplier_email,
        )
      end
      
end
