class SuppliersController < ApplicationController
  before_action :set_supplier, only: %i[show edit update destroy]

  # GET /suppliers
  def index
    @suppliers = Supplier.where(status: ['approved', 'rejected']).order(created_at: :desc)
    respond_to do |format|
      format.html # renders the HTML view (default)
      format.json { render json: @suppliers } # renders JSON response
    end
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
    redirect_to suppliers_url, notice: "Supplier was successfully destroyed.", status: :see_other
  end

  # Approve a supplier
  def approve
    supplier = Supplier.find(params[:id])
    supplier.update_column(:status, 'approved') # Bypass validations
    redirect_to suppliers_path, notice: "Supplier was successfully approved."
  end

  # Reject a supplier
  def reject
    supplier = Supplier.find(params[:id])
    supplier.update_column(:status, 'rejected') # Bypass validations
    redirect_to suppliers_path, notice: "Supplier was successfully rejected."
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
      :password,
      :password_confirmation,
      :status # Allow status updates
    )
  end
end
