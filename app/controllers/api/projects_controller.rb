class Api::ProjectsController < ApplicationController
    def subsystems
      project = Project.find(params[:id])
      render json: project.systems.flat_map(&:subsystems)
    end
  
    def fire_alarm_control_panels
      panel = FireAlarmControlPanel.new(panel_params)
      if panel.save
        render json: { message: "Saved successfully" }, status: :ok
      else
        render json: { errors: panel.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private
  
    def panel_params
      params.permit(
        :standards, :total_no_of_panels, :total_number_of_loop_cards,
        :total_number_of_circuits_per_card_loop, :total_no_of_loops, :total_no_of_spare_loops,
        :total_no_of_detectors_per_loop, :spare_no_of_loops_per_panel,
        :initiating_devices_polarity_insensitivity, :spare_percentage_per_loop,
        :fa_repeater, :auto_dialer, :dot_matrix_printer, :printer_listing,
        :power_standby_24_alarm_5, :power_standby_24_alarm_15,
        :internal_batteries_backup_capacity_panel, :external_batteries_backup_time,
        :subsystem_id
      )
    end
  end
  