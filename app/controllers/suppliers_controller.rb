class SuppliersController < ApplicationController
  before_action :set_supplier, only: %i[show edit update destroy]
  before_action :set_notification, only: [:manage_membership, :approve_supplier, :reject_supplier]
  before_action :set_supplier, only: [:manage_membership, :approve_supplier, :reject_supplier]

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

  
  def approve_supplier
    Rails.logger.info "Params received: #{params.inspect}"
  
    if params[:membership_type].blank? || params[:receive_evaluation_report].blank?
      redirect_to manage_membership_notification_path(@notification, supplier_id: @supplier.id), alert: "Please select all required fields."
      return
    end
  
    ActiveRecord::Base.transaction do
      # Update supplier attributes
      @supplier.update!(
        membership_type: params[:membership_type],
        receive_evaluation_report: params[:receive_evaluation_report] == "true",
        status: "approved"
      )
  
      # Assign projects or subsystems based on membership type
      if params[:membership_type] == "gold"
        selected_projects = params[:project_ids] || []
        @supplier.projects = Project.where(id: selected_projects)
      elsif params[:membership_type] == "silver"
        selected_subsystems = params[:subsystem_ids] || []
        @supplier.subsystems = Subsystem.where(id: selected_subsystems)
      end
  
      # Resolve the notification
      @notification.update!(status: "resolved")
    end
  
    redirect_to notifications_path, notice: "#{@supplier.supplier_name} has been approved with #{params[:membership_type].capitalize} membership."
  rescue => e
    Rails.logger.error "Error in approve_supplier: #{e.message}"
    redirect_to manage_membership_notification_path(@notification, supplier_id: @supplier.id), alert: "Error: #{e.message}"
  end

  def reject_supplier
    @supplier.update!(status: "rejected")
    @notification.update!(status: "resolved")
    redirect_to notifications_path, notice: "#{@supplier.supplier_name} has been rejected."
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

  def assign_membership
    supplier = Supplier.find(params[:id])
    supplier.update!(membership_type: params[:membership_type], receive_evaluation_report: params[:receive_evaluation_report])
    
    if params[:membership_type] == "gold"
      supplier.projects = Project.where(id: params[:project_ids])
    elsif params[:membership_type] == "silver"
      supplier.subsystems = Subsystem.where(id: params[:subsystem_ids])
    end
  
    # Notify Supplier
    Notification.create!(
      title: "Membership Assigned",
      body: "You have been assigned #{supplier.membership_type.capitalize} Membership.",
      notifiable: supplier,
      read: false,
      status: "active"
    )
  
    redirect_to suppliers_path, notice: "Supplier membership and permissions assigned successfully."
  end
  
  def update_membership
    @supplier = Supplier.find(params[:id])

    @supplier.update!(
      membership_type: params[:membership_type],
      receive_evaluation_report: params[:receive_evaluation_report]
    )

    if params[:membership_type] == 'gold'
      project_ids = params[:project_ids]
      @supplier.projects = Project.where(id: project_ids)
    elsif params[:membership_type] == 'silver'
      subsystem_ids = params[:subsystem_ids]
      @supplier.subsystems = Subsystem.where(id: subsystem_ids)
    end

    Notification.create!(
      title: "Membership Updated",
      body: "#{@supplier.supplier_name} has been assigned a #{params[:membership_type]} membership.",
      notifiable: @supplier,
      read: false,
      status: "pending"
    )

    redirect_to notifications_path, notice: "Supplier membership updated successfully."
   rescue StandardError => e
    redirect_to notifications_path, alert: "Error updating supplier: #{e.message}"
  end

  def set_membership_and_approve
    @supplier = Supplier.find(params[:id])

    # Update membership type and permissions
    @supplier.update!(
      membership_type: params[:membership_type],
      receive_evaluation_report: params[:receive_evaluation_report]
    )

    if params[:membership_type] == "gold"
      @supplier.projects = Project.where(id: params[:project_ids])
    elsif params[:membership_type] == "silver"
      @supplier.subsystems = Subsystem.where(id: params[:subsystem_ids])
    end

    # Approve the supplier
    @supplier.update!(status: "approved")

    redirect_to suppliers_path, notice: "#{@supplier.supplier_name} approved with membership type #{params[:membership_type]}."
  end

  def manage_membership
    @projects = Project.all
    @subsystems = Subsystem.all
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
      :membership_type,
      :receive_evaluation_report # Allow status updates
     
    )
  end
end
