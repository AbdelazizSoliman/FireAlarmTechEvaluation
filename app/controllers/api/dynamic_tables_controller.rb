module Api
  class DynamicTablesController < ApplicationController
    before_action :set_table_name, only: %i[index update table_metadata save_data]

    # GET /api/dynamic_tables/:table_name
    def index
      columns = ActiveRecord::Base.connection.columns(@table_name).map(&:name)
      records = ActiveRecord::Base.connection.execute("SELECT * FROM #{@table_name}").to_a
      render json: { columns: columns, data: records }
    end

    # PATCH /api/dynamic_tables/:table_name/:id
    def update
      record_id = params[:id]
      update_params = params.except(:table_name, :id, :controller, :action)

      set_clause = update_params.map do |key, value|
        "#{key} = #{ActiveRecord::Base.connection.quote(value)}"
      end.join(', ')
      sql = "UPDATE #{@table_name} SET #{set_clause} WHERE id = #{record_id}"

      ActiveRecord::Base.connection.execute(sql)
      render json: { message: 'Record updated successfully!' }
    end

    # GET /api/table_metadata/:table_name
    def table_metadata
      @table_name = params[:table_name]
    
      metadata = ColumnMetadata.where(table_name: @table_name).each_with_object({}) do |meta, hash|
        hash[meta.column_name] = {
          feature: meta.feature,
          options: meta.options,
          row: meta.row,
          col: meta.col,
          label_row: meta.label_row,
          label_col: meta.label_col
        }
      end
    
      render json: {
        columns: metadata.keys,
        metadata: metadata
      }
    end
    

    # POST /api/save_data/:table_name
    def save_data
      data = params[:data].permit!.to_h # Permit all for dynamic columns, adjust as needed
      model_class = @table_name.classify.constantize rescue nil
      unless model_class
        render json: { error: "Table #{@table_name} not found" }, status: :not_found and return
      end

      record = model_class.new(data)
      if record.save
        render json: { success: true, record: record.as_json }, status: :created
      else
        render json: { error: record.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_table_name
      @table_name = params[:table_name]
      unless ActiveRecord::Base.connection.table_exists?(@table_name)
        render json: { error: "Table #{@table_name} not found" }, status: :not_found and return
      end
    end
  end
end