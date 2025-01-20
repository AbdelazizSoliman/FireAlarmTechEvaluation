module Api
    class SubsystemsController < ApplicationController
      def submit_all
        subsystem = Subsystem.find(params[:id])
  
        # Example logic for processing data
        fire_alarm_data = params[:fire_alarm_control_panel]
        detectors_data = params[:detectors_field_devices]
  
        if fire_alarm_data.present? && detectors_data.present?
          # Save data or process as needed
          Notification.create!(
            title: "Evaluation Submitted",
            body: "Evaluation for subsystem ##{subsystem.id} has been submitted.",
            notifiable: subsystem,
            notification_type: "evaluation",
            additional_data: { subsystem_id: subsystem.id }.to_json
          )
          render json: { message: "Data submitted successfully." }, status: :created
        else
          render json: { error: "Invalid data provided." }, status: :unprocessable_entity
        end
      end
    end
  end
  