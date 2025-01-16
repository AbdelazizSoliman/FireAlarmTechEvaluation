class FireAlarmControlPanelsController < ApplicationController
  def create
    # Locate the subsystem through the nested scope
    project = Project.find(params[:project_id])
    project_scope = project.project_scopes.find(params[:project_scope_id])
    system = project_scope.systems.find(params[:system_id])
    subsystem = system.subsystems.find(params[:subsystem_id])

    # Create a new FireAlarmControlPanel associated with the subsystem
    fire_alarm_control_panel = subsystem.fire_alarm_control_panels.new(fire_alarm_control_panel_params)

    if fire_alarm_control_panel.save
      render json: { message: "Fire Alarm Control Panel created successfully." }, status: :created
    else
      render json: { errors: fire_alarm_control_panel.errors.full_messages }, status: :unprocessable_entity
    end
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
end
