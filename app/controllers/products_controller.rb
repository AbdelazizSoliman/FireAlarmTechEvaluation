class ProductController < ApplicationController
    def index  
        @product = Product.all  
      end  
    
      def show  
        @product = Product.find(params[:id])  
      end  
    
      def new  
        @product = Product.new  
      end  
    
      def create  
        @product = Product.new(product_data_params)  
        if @product.save  
          redirect_to product_data_path, notice: 'Product data was successfully created.'  
        else  
          render :new  
        end  
      end  
    
      def edit  
        @product = Product.find(params[:id])  
      end  
    
      def update  
        @product = Product.find(params[:id])  
        if @product.update(product_data_params)  
          redirect_to product_data_path, notice: 'Product data was successfully updated.'  
        else  
          render :edit  
        end  
      end  
    
      def destroy  
        @product = Product.find(params[:id])  
        @product.destroy  
        redirect_to product_data_path, notice: 'Product data was successfully deleted.'  
      end  
    
      private  
    
      def product_params  
        params.require(:product).permit(:product_name, :country_of_origin, :country_of_manufacture_fc, :country_of_manufacture_detectors)  
      end  
end
