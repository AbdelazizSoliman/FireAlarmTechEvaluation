class ProductController < ApplicationController
    def index  
        @product_data = ProductDatum.all  
      end  
    
      def show  
        @product = ProductDatum.find(params[:id])  
      end  
    
      def new  
        @product = ProductDatum.new  
      end  
    
      def create  
        @product = ProductDatum.new(product_data_params)  
        if @product.save  
          redirect_to product_data_path, notice: 'Product data was successfully created.'  
        else  
          render :new  
        end  
      end  
    
      def edit  
        @product = ProductDatum.find(params[:id])  
      end  
    
      def update  
        @product = ProductDatum.find(params[:id])  
        if @product.update(product_data_params)  
          redirect_to product_data_path, notice: 'Product data was successfully updated.'  
        else  
          render :edit  
        end  
      end  
    
      def destroy  
        @product = ProductDatum.find(params[:id])  
        @product.destroy  
        redirect_to product_data_path, notice: 'Product data was successfully deleted.'  
      end  
    
      private  
    
      def product_data_params  
        params.require(:product_data).permit(:name, :country_of_origin, :country_of_manufacture_fc, :country_of_manufacture_detectors)  
      end  
end
