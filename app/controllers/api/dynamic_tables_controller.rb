module Api
  class DynamicTablesController < ApplicationController
    # before_action :set_table_name, only: %i[index update table_metadata save_data]
    skip_forgery_protection

    def save_all
      supplier = authenticate_supplier! || (return head :unauthorized)
      all_payloads = params.require(:data).permit!.to_h

      ActiveRecord::Base.transaction do
        all_payloads.each do |table_name, payload|
          # … your dynamic‐model upsert logic from before …
        end

        # 🔔 Notify Admin
        Notification.create!(
          title:   "New Submission by #{supplier.supplier_name}",
          body:    "Supplier ##{supplier.id} has submitted data for subsystem #{all_payloads.values.first['subsystem_id']}.",
          notifiable: nil,                     # or link it to a Subsystem/ProjectScope
          notification_type: 'submission',
          additional_data: all_payloads.to_json
        )
      end

      render json: { message: "All tables saved." }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    # GET /api/dynamic_tables/:table_name
    def index
      table_def = TableDefinition.find_by(table_name: @table_name)
      is_static = table_def&.static?
    
      columns = ActiveRecord::Base.connection.columns(@table_name).map(&:name)
      records = ActiveRecord::Base.connection.execute("SELECT * FROM #{@table_name}").to_a
      render json: { columns: columns, data: records, static: is_static }
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
      table_def = TableDefinition.find_by(table_name: @table_name)
    
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
        metadata: metadata,
        static: table_def&.static || false # <--- Add this
      }
    end
    
    

    # POST /api/save_data/:table_name
    def save_data
      supplier   = authenticate_supplier!
      return render json: { error: 'Unauthorized' }, status: :unauthorized unless supplier

      table_name   = params[:table_name]
      payload      = params.require(:data).permit!   # all incoming form fields
      subsystem_id = payload.delete("subsystem_id") || payload.delete(:subsystem_id)
      model        = table_name.classify.constantize

      record = model.where(supplier_id: supplier.id, subsystem_id: subsystem_id)
                    .first_or_initialize
      record.assign_attributes(payload)
      record.supplier_id  = supplier.id
      record.subsystem_id = subsystem_id

      if record.save
        render json: { message: "Data for #{table_name} saved." }, status: :created
      else
        render json: { error: record.errors.full_messages }, status: :unprocessable_entity
      end
    rescue NameError
      render json: { error: "Invalid table: #{table_name}" }, status: :bad_request
    end
    private

    def authenticate_supplier!
      token = request.headers['Authorization']&.split(' ')&.last
      return unless token
      payload = JWT.decode(token, Rails.application.secret_key_base,
                           true, algorithm: 'HS256').first
      ::Supplier.find_by(id: payload['sub'])
    rescue
      nil
    end
  end
end