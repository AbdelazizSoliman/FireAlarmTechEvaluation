class FireAlarmControlPanelsController < ApplicationController
  before_action :set_project_system_subsystem

  def new
    @fire_alarm_control_panel = FireAlarmControlPanel.new
  end

  def create
    @fire_alarm_control_panel = FireAlarmControlPanel.new(fire_alarm_control_panel_params)
    @fire_alarm_control_panel.subsystem_id = @subsystem.id
    if @fire_alarm_control_panel.save
      redirect_to project_system_subsystem_path(@project, @system, @subsystem), notice: 'Fire Alarm Control Panel created successfully.'
    else
      render :new
    end
  end

  private

  def set_project_system_subsystem
    @project = Project.find(params[:project_id])
    @system = System.find(params[:system_id])
    @subsystem = Subsystem.find(params[:subsystem_id])
  end

  def fire_alarm_control_panel_params
    params.require(:fire_alarm_control_panel).permit(
      :standards, :total_no_of_panels, :total_number_of_loop_cards,
      :total_number_of_circuits_per_card_loop, :total_no_of_loops,
      :total_no_of_spare_loops, :total_no_of_detectors_per_loop,
      :spare_no_of_loops_per_panel, :initiating_devices_polarity_insensitivity,
      :spare_percentage_per_loop, :fa_repeater, :auto_dialer, :dot_matrix_printer,
      :printer_listing, :power_standby_24_alarm_5, :power_standby_24_alarm_15,
      :internal_batteries_backup_capacity_panel, :external_batteries_backup_time
    )
  end
end
