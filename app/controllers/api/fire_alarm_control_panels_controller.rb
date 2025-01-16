module Api
  class FireAlarmControlPanelsController < ApplicationController
    skip_before_action :verify_authenticity_token

    COMPARISON_FIELDS = {
  total_no_of_panels: { sheet_row: 1, sheet_column: 2 },
  total_number_of_loop_cards: { sheet_row: 1, sheet_column: 3 },
  total_number_of_circuits_per_card_loop: { sheet_row: 1, sheet_column: 4 },
  total_no_of_loops: { sheet_row: 1, sheet_column: 5 },
  total_no_of_spare_loops: { sheet_row: 1, sheet_column: 6 },
  total_no_of_detectors_per_loop: { sheet_row: 1, sheet_column: 7 },
  spare_no_of_loops_per_panel: { sheet_row: 1, sheet_column: 8 },
  spare_percentage_per_loop: { sheet_row: 1, sheet_column: 10},
  fa_repeater: { sheet_row: 1, sheet_column: 11 },
  auto_dialer: { sheet_row: 1, sheet_column: 12 },
  dot_matrix_printer: { sheet_row: 1, sheet_column: 13 },
  internal_batteries_backup_capacity_panel: { sheet_row: 1, sheet_column: 17 },
  external_batteries_backup_time: { sheet_row: 1, sheet_column: 18 }
}

    def create
      project = Project.find(params[:project_id])
      project_scope = project.project_scopes.find(params[:project_scope_id])
      system = project_scope.systems.find(params[:system_id])
      subsystem = Subsystem.find(params[:subsystem_id])

      # Create a new FireAlarmControlPanel associated with the subsystem
      fire_alarm_control_panel = subsystem.fire_alarm_control_panels.new(fire_alarm_control_panel_params)

      if fire_alarm_control_panel.save
        # Evaluate the submitted data against standards
        comparison_result = evaluate_fire_alarm_data(fire_alarm_control_panel)

        # Generate the evaluation report as a PDF
        report_path = generate_pdf_report(fire_alarm_control_panel, comparison_result)

        # Create a notification for the evaluation
        Notification.create!(
          title: "New Evaluation Submitted",
          body: "#{subsystem.name}: Evaluation report has been generated.",
          notifiable: fire_alarm_control_panel,
          notification_type: "evaluation",
          additional_data: {
            evaluation_report_path: report_path.sub(Rails.root.join('public').to_s, '') # Use relative path
          }.to_json
        )
        

        render json: { message: "Fire Alarm Control Panel created successfully. Report generated." }, status: :created
      else
        render json: { errors: fire_alarm_control_panel.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def index
      subsystem = Subsystem.find(params[:subsystem_id])
      fire_alarm_control_panels = subsystem.fire_alarm_control_panels

      render json: fire_alarm_control_panels, status: :ok
    end

    private

    def fire_alarm_control_panel_params
      params.require(:fire_alarm_control_panel).permit(
        :standards,
        :total_no_of_panels,
        :total_number_of_loop_cards,
        :total_number_of_circuits_per_card_loop,
        :total_no_of_loops,
        :total_no_of_spare_loops,
        :total_no_of_detectors_per_loop,
        :spare_no_of_loops_per_panel,
        :initiating_devices_polarity_insensitivity,
        :spare_percentage_per_loop,
        :fa_repeater,
        :auto_dialer,
        :dot_matrix_printer,
        :printer_listing,
        :power_standby_24_alarm_5,
        :power_standby_24_alarm_15,
        :internal_batteries_backup_capacity_panel,
        :external_batteries_backup_time
      )
    end

    # Method to evaluate data
    def evaluate_fire_alarm_data(panel)
      standard_file_path = Rails.root.join('lib', 'standard_fire_alarm_control_panel.xlsx')
      standard_workbook = RubyXL::Parser.parse(standard_file_path)
      standard_sheet = standard_workbook[0]
    
      results = COMPARISON_FIELDS.map do |field, location|
        # Fetch the submitted value
        submitted_value = panel.send(field)
    
        # Fetch the standard value from the Excel sheet
        standard_value = standard_sheet[location[:sheet_row]][location[:sheet_column]].value
    
        # Perform the comparison
        is_accepted = submitted_value.present? && submitted_value.to_i >= standard_value.to_i
    
        # Return comparison result for this field
        {
          field: field,
          submitted_value: submitted_value,
          standard_value: standard_value,
          is_accepted: is_accepted
        }
      end
    
      results
    end
    

    # Method to generate PDF report
    def generate_pdf_report(panel, comparison_results)
      file_name = "evaluation_report_#{panel.id}_#{Time.now.to_i}.pdf"
      file_path = Rails.root.join('public', 'reports', file_name)
    
      Prawn::Document.generate(file_path) do |pdf|
        # Title
        pdf.text "Evaluation Report", size: 30, style: :bold, align: :center
        pdf.move_down 20
    
        # Subtitle
        pdf.text "Evaluation Results", size: 20, style: :bold, align: :left
        pdf.move_down 10
    
        # Prepare data for the table
        table_data = [
          ["Attribute", "Submitted", "Standard", "Status"] # Header row
        ]
    
        # Populate table rows
        comparison_results.each do |result|
          status = result[:is_accepted] ? "1" : "0" # 1 for Accepted, 0 for Rejected
          table_data << [
            result[:field].to_s.humanize,          # Field name
            result[:submitted_value] || "N/A",    # Submitted value
            result[:standard_value] || "N/A",     # Standard value
            status                                # Status
          ]
        end
    
        # Add the table to the PDF with styles
        pdf.table(table_data, header: true, position: :center, width: pdf.bounds.width) do
          row(0).font_style = :bold
          row(0).background_color = "00FF00" # Green for the header
          self.row_colors = ["F0F8FF", "FFFFFF"] # Alternate row colors
          self.cell_style = { borders: [:top, :bottom], padding: [5, 10] }
        end
    
        pdf.move_down 20
    
        # Overall Status
        overall_status = comparison_results.all? { |r| r[:is_accepted] } ? "Accepted" : "Rejected"
        pdf.text "Overall Status: #{overall_status}", size: 25, style: :bold, align: :center, color: overall_status == "Accepted" ? "008000" : "FF0000"
      end
    
      file_path.to_s
    end
    
    
  end
end
