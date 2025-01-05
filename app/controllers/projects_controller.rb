class ProjectsController < ApplicationController  

  def index  
    @projects = Project.all  # This will fetch all project records  
  end  

  def show
    @project = Project.includes(:product, :fire_alarm_control_panel, :graphic_system).find(params[:id])
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

  def download_excel  
    @project = Project.includes(:product, :fire_alarm_control_panel, :graphic_system).find(params[:id])  
  
    Axlsx::Package.new do |p|  
      p.workbook.add_worksheet(name: "Project Data") do |sheet|  
        # Add headers  
        sheet.add_row ["Project ID", "Product Name", "Country of Origin", "Manufacture (FC)", "Manufacture (Detectors)",   
                       "MFCAP", "Standards", "Total No of Panels",   
                       "Workstation", "Control Feature", "Softwares"]  
  
        # Add data row for the specific project  
        sheet.add_row [  
          @project.id,  
          @project.product&.product_name,  
          @project.product&.country_of_origin,  
          @project.product&.country_of_manufacture_mfacp,  
          @project.product&.country_of_manufacture_detectors,  
          @project.fire_alarm_control_panel&.mfacp,  
          @project.fire_alarm_control_panel&.standards,  
          @project.fire_alarm_control_panel&.total_no_of_panels,  
          @project.graphic_system&.workstation,  
          @project.graphic_system&.workstation_control_feature,  
          @project.graphic_system&.softwares  
        ]  
      end  
  
      # Send the file as a response  
      send_data p.to_stream.read,  
                filename: "project_#{@project.id}_data.xlsx",  
                type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"  
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
