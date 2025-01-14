class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update]

  def index
    @projects = Project.all.includes(:project_scopes) # Include associated project scopes for better query performance
  end

  def edit
    # Render the edit form for the project
  end

  def update
    # Render the edit form for the project
  end

  def show
    @project = Project.find(params[:id])
    @project_scopes = @project.project_scopes
  end

  def new
    @project = Project.new
  end


  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to @project, notice: 'Project was successfully created.'
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

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name)
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
