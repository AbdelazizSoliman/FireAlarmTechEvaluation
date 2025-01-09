class SubsystemSuppliersController < ApplicationController
    def create
      @subsystem_supplier = SubsystemSupplier.new(subsystem_supplier_params)
      if @subsystem_supplier.save
        redirect_to subsystem_path(@subsystem_supplier.subsystem), notice: "Supplier assigned successfully!"
      else
        render :new
      end
    end
  
    private
  
    def subsystem_supplier_params
      params.require(:subsystem_supplier).permit(:subsystem_id, :supplier_id)
    end
  end
  