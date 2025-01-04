class ProjectsController < ApplicationController  

  def index  
    @projects = Project.all  # This will fetch all project records  
  end  

  def new  
    @project = Project.new
    @project.build_product
    @project.build_fire_alarm_control_panel
    @project.build_graphic_system
  end  

  def create  
    @project = Project.new(project_params)  

    if @project.save  
      redirect_to projects_path, notice: 'Project and all associated data were successfully created.'  
    else  
      render :new  
    end  
  end  

  private  

  def project_params
    params.require(:project).permit(
      :attribute_1, :attribute_2, # Replace with your actual Project attributes
      product_attributes: [:product_name, :country_of_origin, :country_of_manufacture_fc, :country_of_manufacture_detectors],
      fire_alarm_control_panel_attributes: [:mfacp, :standards, :total_no_of_panels, :total_number_of_loop_cards, :total_number_of_circuits_per_card_loop, :total_no_of_loops, :total_no_of_spare_loops, :total_no_of_detectors_per_loop, :spare_no_of_loops_per_panel, :initiating_devices_polarity_insensitivity, :spare_percentage_per_loop, :fa_repeater, :auto_dialer, :dot_matrix_printer, :printer_listing, :backup_time, :power_standby_24_alarm_5, :power_standby_24_alarm_15, :internal_batteries_backup_capacity_panel, :external_batteries_backup_time],
      graphic_system_attributes: [:workstation, :workstation_control_feature, :softwares, :licenses, :screens]
    )
  end
end
