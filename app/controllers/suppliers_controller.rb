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
    @supplier = Supplier.find(params[:id])
    if @supplier.membership_type == "projects"
      @projects = Project.all
    elsif @supplier.membership_type == "systems"
      @subsystems = Subsystem.all
    end
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
      if @supplier.membership_type == "projects"
        selected_projects = params[:project_ids] || []
        @supplier.projects = Project.where(id: selected_projects)
        @supplier.subsystems.clear
      elsif @supplier.membership_type == "systems"
        selected_subsystems = params[:subsystem_ids] || []
        @supplier.subsystems = Subsystem.where(id: selected_subsystems)
        @supplier.projects.clear
      end
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
    Rails.logger.info "Params: #{params.inspect}"
    
    @supplier = Supplier.find(params[:supplier_id])
    @notification = Notification.find(params[:id])
  
    ActiveRecord::Base.transaction do
      @supplier.update!(
        membership_type: params[:membership_type],
        receive_evaluation_report: params[:receive_evaluation_report] == "true",
        status: "approved"
      )
  
      if params[:membership_type] == "projects"
        selected_projects = params[:project_ids] || []
        @supplier.projects = Project.where(id: selected_projects)
        Rails.logger.info "Projects saved: #{@supplier.projects.pluck(:id)}"
      elsif params[:membership_type] == "systems"
        selected_subsystems = params[:subsystem_ids] || []
        @supplier.subsystems = Subsystem.where(id: selected_subsystems)
        Rails.logger.info "Subsystems saved: #{@supplier.subsystems.pluck(:id)}"
      end
  
      @notification.update!(status: "resolved")
    end
  
    redirect_to suppliers_path, notice: "#{@supplier.supplier_name} has been approved."
  rescue => e
    Rails.logger.error "Error in approve_supplier: #{e.message}"
    redirect_to manage_membership_notification_path(@notification, supplier_id: @supplier.id), alert: "Error: #{e.message}"
  end
  
  

  def reject_supplier
    supplier = Supplier.find(params[:id])
    supplier.update_column(:status, 'rejected') # Bypass validations
    redirect_to suppliers_path, notice: "Supplier was successfully rejected."
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
    
    if params[:membership_type] == "projects"
      supplier.projects = Project.where(id: params[:project_ids])
    elsif params[:membership_type] == "systems"
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
  
    ActiveRecord::Base.transaction do
      # Remove existing associations based on the previous membership type
      if @supplier.membership_type == "projects"
        @supplier.projects.clear # Remove all project associations
      elsif @supplier.membership_type == "systems"
        @supplier.subsystems.clear # Remove all subsystem associations
      end
  
      # Update membership type and permissions
      @supplier.update!(
        membership_type: params[:membership_type],
        receive_evaluation_report: params[:receive_evaluation_report]
      )
  
      # Assign new associations based on the updated membership type
      if params[:membership_type] == "projects"
        project_ids = params[:project_ids] || []
        @supplier.projects = Project.where(id: project_ids)
      elsif params[:membership_type] == "systems"
        subsystem_ids = params[:subsystem_ids] || []
        @supplier.subsystems = Subsystem.where(id: subsystem_ids)
      end
  
      # Notify Supplier
      Notification.create!(
        title: "Membership Updated",
        body: "#{@supplier.supplier_name} has been assigned a #{params[:membership_type]} membership.",
        notifiable: @supplier,
        read: false,
        status: "pending"
      )
    end
  
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

    if params[:membership_type] == "projects"
      @supplier.projects = Project.where(id: params[:project_ids])
    elsif params[:membership_type] == "systems"
      @supplier.subsystems = Subsystem.where(id: params[:subsystem_ids])
    end

    # Approve the supplier
    @supplier.update!(status: "approved")

    redirect_to suppliers_path, notice: "#{@supplier.supplier_name} approved with membership type #{params[:membership_type]}."
  end

  def dashboard
    supplier = Supplier.find_by(id: params[:supplier_id])
  
    if supplier.nil?
      render json: { error: "Supplier not found" }, status: :not_found
      return
    end
  
    # Log supplier details and subsystems for debugging
    Rails.logger.info "Supplier: #{supplier.inspect}"
    Rails.logger.info "Subsystems: #{supplier.subsystems.to_json}"
  
    render json: {
      id: supplier.id,
      supplier_name: supplier.supplier_name,
      membership_type: supplier.membership_type,
      projects: supplier.membership_type == "projects" ? supplier.projects.select(:id, :name) : [],
      subsystems: supplier.membership_type == "systems" ? supplier.subsystems.select(:id, :name, :system_id) : []
    }
  end
  

  def dashboard
    supplier = Supplier.find_by(id: params[:supplier_id])
  
    if supplier.nil?
      render json: { error: "Supplier not found" }, status: :not_found
      return
    end
  
    # Log supplier details and subsystems for debugging
    Rails.logger.info "Supplier: #{supplier.inspect}"
    Rails.logger.info "Subsystems: #{supplier.subsystems.to_json}"
  
    render json: {
      id: supplier.id,
      supplier_name: supplier.supplier_name,
      membership_type: supplier.membership_type,
      projects: supplier.membership_type == "projects" ? supplier.projects.select(:id, :name) : [],
      subsystems: supplier.membership_type == "systems" ? supplier.subsystems.select(:id, :name, :system_id) : []
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
      status: supplier.status,
      membership_type: supplier.membership_type,
      projects: supplier.membership_type == "projects" ? supplier.projects : [],
      subsystems: supplier.membership_type == "systems" ? supplier.subsystems : []
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
      :membership_type,
      :receive_evaluation_report # Allow status updates
     
    )
  end
end
