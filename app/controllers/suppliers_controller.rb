class SuppliersController < ApplicationController
  before_action :set_supplier, only: %i[show edit update destroy]
  before_action :set_notification, only: [:manage_membership, :approve_supplier, :reject_supplier]
  # before_action :set_supplier, only: [:manage_membership, :approve_supplier, :reject_supplier]

  # GET /suppliers
  def index
    @suppliers = Supplier.where(status: ['approved', 'rejected', 'pending']).order(created_at: :desc)
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
  end

  # DELETE /suppliers/1
  def destroy
    @supplier.destroy!
    redirect_to suppliers_url, notice: "Supplier was successfully destroyed.", status: :see_other
  end

  
  def approve_supplier
    @notification = Notification.find(params[:id])
    @supplier = @notification.notifiable
  
    ActiveRecord::Base.transaction do
      # Update supplier details
      @supplier.update!(
        receive_evaluation_report: params[:receive_evaluation_report] == "true",
        status: "approved"
      )
  
      # Approve selected projects
      @supplier.projects.where(id: params[:project_ids]).update_all(approved: true)
  
      # Approve selected project scopes
      @supplier.project_scopes.where(id: params[:project_scope_ids]).update_all(approved: true)
  
      # Approve selected systems
      @supplier.systems.where(id: params[:system_ids]).update_all(approved: true)
  
      # Approve selected subsystems
      @supplier.subsystems.where(id: params[:subsystem_ids]).update_all(approved: true)
  
      # Resolve notification
      @notification.update!(status: "resolved")
    end
  
    redirect_to notifications_path, notice: "Supplier approved successfully."
  rescue => e
    redirect_to manage_membership_notification_path(@notification, supplier_id: @supplier.id),
                alert: "Error: #{e.message}"
  end
  
  
  
  

  def reject_supplier
    notification = Notification.find(params[:id])
    supplier = notification.notifiable
  
    supplier.update!(status: "rejected")
    notification.update!(status: "resolved")
  
    render json: { message: "Supplier rejected successfully" }
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
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

  def manage_membership
    @notification = Notification.find(params[:id])
    @supplier = @notification.notifiable
  
    # Ensure selected items are loaded
    @projects = @supplier.projects
    @project_scopes = @supplier.project_scopes
    @systems = @supplier.systems
    @subsystems = @supplier.subsystems
  end
  

  def dashboard
    supplier = Supplier.find_by(id: params[:supplier_id])
  
    if supplier.nil?
      render json: { error: "Supplier not found" }, status: :not_found
      return
    end
  
    # Fetch subsystems associated with the supplier
    subsystems = supplier.subsystems.map do |subsystem|
      {
        id: subsystem.id,
        name: subsystem.name,
        system_id: subsystem.system_id,
        project_id: subsystem.system.project_scope.project_id, # Assuming associations are correctly set up
        project_scope_id: subsystem.system.project_scope.id   # Assuming associations are correctly set up
      }
    end
  
    render json: {
      id: supplier.id,
      supplier_name: supplier.supplier_name
    }
  end
  
  
  
  

  def profile
    supplier = Supplier.find(params[:supplier_id])
  
    if supplier.nil?
      render json: { error: "Supplier not found" }, status: :not_found
      return
    end
  
    render json: {
      id: supplier.id,
      supplier_name: supplier.supplier_email,
      supplier_email: supplier.supplier_email,
      supplier_category: supplier.supplier_category,
      phone: supplier.phone,
      total_years_in_saudi_market: supplier.total_years_in_saudi_market,
      status: supplier.status
    }
  end
  
  
  
  private

  def set_notification
    @notification = Notification.find(params[:id])
  end
  
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
      :status,
      :receive_evaluation_report # Allow status updates
     
    )
  end
end
