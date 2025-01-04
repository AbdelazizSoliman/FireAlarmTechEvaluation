class FireAlarmControlPanelController < ApplicationController
      def index  
        @fire_alarm_control_panels = FireAlarmControlPanel.all  
      end  
    
      def show  
        @fire_alarm_control_panel = FireAlarmControlPanel.find(params[:id])  
      end  
    
      def new  
        @fire_alarm_control_panel = FireAlarmControlPanel.new  
      end  
    
      def create  
        @fire_alarm_control_panel = FireAlarmControlPanel.new(fire_alarm_control_panel_params)  
        if @fire_alarm_control_panel.save  
          redirect_to fire_alarm_control_panels_path, notice: 'Fire Alarm Control Panel was successfully created.'  
        else  
          render :new  
        end  
      end  
    
      def edit  
        @fire_alarm_control_panel = FireAlarmControlPanel.find(params[:id])  
      end  
    
      def update  
        @fire_alarm_control_panel = FireAlarmControlPanel.find(params[:id])  
        if @fire_alarm_control_panel.update(fire_alarm_control_panel_params)  
          redirect_to fire_alarm_control_panels_path, notice: 'Fire Alarm Control Panel was successfully updated.'  
        else  
          render :edit  
        end  
      end  
    
      def destroy  
        @fire_alarm_control_panel = FireAlarmControlPanel.find(params[:id])  
        @fire_alarm_control_panel.destroy  
        redirect_to fire_alarm_control_panels_path, notice: 'Fire Alarm Control Panel was successfully deleted.'  
      end  
    
      private  
    
      def fire_alarm_control_panel_params  
        params.require(:fire_alarm_control_panel).permit(  
          :mfacp,  
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
          :backup_time,  
          :power_standby_24_alarm_5,  
          :power_standby_24_alarm_15,  
          :internal_batteries_backup_capacity_panel,  
          :external_batteries_backup_time  
        )  
      end
end