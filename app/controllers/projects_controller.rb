class ProjectsController < ApplicationController
  def index
    @projects = Project.all.includes(:systems) # Include associated systems to optimize queries
  end

  def show
    @project = Project.find(params[:id])
    @fire_alarm_panels = @project.systems.flat_map do |system|
      system.subsystems.flat_map(&:fire_alarm_control_panels)
    end
  end
  

  def new
    @project = Project.new
    @project.systems.build # Build associated systems
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      # Evaluate the project data after saving
      comparison_result = evaluate_project_data(@project)

      # Generate the PDF report based on the comparison results
      generate_pdf_report(comparison_result)

      # Flash message based on evaluation results
      if comparison_result.first
        redirect_to projects_path, notice: "The project data meets the required criteria. Report generated."
      else
        redirect_to projects_path, alert: "The project data does not meet the required criteria. Report generated."
      end
    else
      render :new
    end
  end

  def download_excel
    @project = Project.find(params[:id])
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: "Project Data") do |sheet|
        # Add headers
        sheet.add_row [
          "Project ID", "System Name", "Subsystem Name", "MFCAP", "Standards", 
          "Total No of Panels", "Loop Cards", "Circuits Per Card Loop"
        ]

        # Add data rows for the project
        @project.systems.each do |system|
          system.subsystems.each do |subsystem|
            subsystem.fire_alarm_control_panels.each do |panel|
              sheet.add_row [
                @project.id, system.name, subsystem.name, panel.mfacp, panel.standards, 
                panel.total_no_of_panels, panel.total_number_of_loop_cards, 
                panel.total_number_of_circuits_per_card_loop
              ]
            end
          end
        end
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
      :name, # Project attributes
      systems_attributes: [
        :id, :name, :_destroy,
        subsystems_attributes: [
          :id, :name, :_destroy,
          fire_alarm_control_panels_attributes: [
            :id, :standards, :total_no_of_panels, :total_number_of_loop_cards, 
            :total_number_of_circuits_per_card_loop, :total_no_of_loops, 
            :total_no_of_spare_loops, :total_no_of_detectors_per_loop, 
            :spare_no_of_loops_per_panel, :initiating_devices_polarity_insensitivity, 
            :spare_percentage_per_loop, :fa_repeater, :auto_dialer, :dot_matrix_printer, 
            :printer_listing, :power_standby_24_alarm_5, :power_standby_24_alarm_15, 
            :internal_batteries_backup_capacity_panel, :external_batteries_backup_time
          ]
        ]
      ]
    )
  end

  def evaluate_project_data(project)
    # Evaluation logic here
    # Placeholder for comparison logic
    [true, true] # Example: Always accepted for now
  end

  def generate_pdf_report(comparison_result)
    Prawn::Document.generate(Rails.root.join('public', "report_#{Time.now.to_i}.pdf")) do |pdf|
      pdf.text "Comparison Report", size: 30, style: :bold
      pdf.move_down 20
      pdf.text "Report content goes here..."
    end
  end
end
