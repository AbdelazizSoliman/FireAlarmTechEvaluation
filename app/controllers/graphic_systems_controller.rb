class GraphicSystemsController < ApplicationController
    def index  
        @graphic_systems = GraphicSystem.all  
      end  
    
      def show  
        @graphic_system = GraphicSystem.find(params[:id])  
      end  
    
      def new  
        @graphic_system = GraphicSystem.new  
      end  
    
      def create  
        @graphic_system = GraphicSystem.new(graphic_system_params)  
        if @graphic_system.save  
          redirect_to graphic_systems_path, notice: 'Graphic system was successfully created.'  
        else  
          render :new  
        end  
      end  
    
      def edit  
        @graphic_system = GraphicSystem.find(params[:id])  
      end  
    
      def update  
        @graphic_system = GraphicSystem.find(params[:id])  
        if @graphic_system.update(graphic_system_params)  
          redirect_to graphic_systems_path, notice: 'Graphic system was successfully updated.'  
        else  
          render :edit  
        end  
      end  
    
      def destroy  
        @graphic_system = GraphicSystem.find(params[:id])  
        @graphic_system.destroy  
        redirect_to graphic_systems_path, notice: 'Graphic system was successfully deleted.'  
      end  
    
      private  
    
      def graphic_system_params  
        params.require(:graphic_system).permit(:workstation, :workstation_control_feature, :softwares, :licenses, :screens)  
      end  
end
