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
      # Automatically evaluate the project data after saving  
      comparison_result = evaluate_project_data(@project)  

      # Generate the PDF report based on the comparison results  
      generate_pdf_report(comparison_result)  

      # Set flash message based on the evaluation results  
      if comparison_result.first # Check if the comparison is accepted  
        redirect_to projects_path, notice: "The project data meets the required criteria. Report generated."  
      else  
        redirect_to projects_path, alert: "The project data does not meet the required criteria. Report generated."  
      end  
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

  # Method for evaluating project data  
  def evaluate_project_data(project)  
    # Load the standard comparison data from a predefined Excel file  
    standard_file_path = Rails.root.join('lib', 'standard_comparison_data.xlsx') # Adjust this path accordingly  
    standard_workbook = RubyXL::Parser.parse(standard_file_path)  
    standard_sheet = standard_workbook[0]  

    # Acquire project data to compare.  
    total_no_of_panels = project.fire_alarm_control_panel&.total_no_of_panels  # Get the project field for Total No of Panels  

    # Get the standard value for Total No of Panels (Assuming it's in Row 2, Column 5)  
    standard_value = standard_sheet[1][7].value  # Change according to the correct row/column for your data  

    # Check if the Total No of Panels is equal to or greater than the standard value of 100.  
    comparison_result = total_no_of_panels.present? && total_no_of_panels.to_i >= standard_value.to_i  

    # Return the result as an array containing:  
    # [Comparison Result (true or false), Uploaded Value, Standard Value]  
    [comparison_result, total_no_of_panels, standard_value]  
  end  

  # Method for generating PDF report  
  def generate_pdf_report(comparison_result)  
    Prawn::Document.generate(Rails.root.join('public', "report_#{Time.now.to_i}.pdf")) do |pdf|  
      pdf.text "Comparison Report", size: 30, style: :bold  
      pdf.move_down 20  

      pdf.text "Comparison Results:", size: 20, style: :bold  
      is_accepted, uploaded, standard = comparison_result  
      status = is_accepted ? "Accepted" : "Rejected"  
      pdf.text "Total No of Panels: #{status} (Uploaded: #{uploaded}, Standard: #{standard})"  

      overall_status = is_accepted ? "Accepted" : "Rejected"  
      pdf.move_down 20  
      pdf.text "Overall Status: #{overall_status}", size: 25, style: :bold  
    end  
  end  
end