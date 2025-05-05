# app/controllers/api/dynamic_tables_controller.rb
module Api
  class DynamicTablesController < ApplicationController
    skip_forgery_protection

    def table_definitions
      defs = TableDefinition.where(subsystem_id: params[:subsystem_id])
                            .order(:position)
                            .pluck(:table_name, :parent_table, :position)
                            .map { |name, parent, pos| { table_name: name, parent_table: parent, position: pos } }
      render json: defs
    end

    # POST /api/save_all
    def save_all
      payloads = params.require(:data).to_unsafe_h  # your incoming per-table hashes
      # 1) fetch all defs in two‐phase order: parents first
      table_defs = TableDefinition
        .where(subsystem_id: params[:subsystem_id])
        .order(Arel.sql("COALESCE(parent_table, '') ASC, position ASC"))
    
      table_defs.each do |td|
        name = td.table_name
        next unless payloads.key?(name)
    
        raw    = payloads[name] || {}
        model  = Class.new(ActiveRecord::Base) do
          self.table_name        = name
          self.inheritance_column = :_type_disabled
        end
    
        # 2) strip everything except real columns
        allowed = model.column_names
        safe    = raw.slice(*allowed)
                     .except("id","created_at","updated_at","supplier_id","subsystem_id")
    
        # 3) if this is a child table, look up its parent record & wire the FK
        if td.parent_table.present?
          parent_rec = Class.new(ActiveRecord::Base) {
            self.table_name        = td.parent_table
            self.inheritance_column = :_type_disabled
          }.find_by(supplier_id: safe["supplier_id"], subsystem_id: safe["subsystem_id"])
    
          # only set it if we actually found a parent
          safe["parent_id"] = parent_rec.id if parent_rec
        end
    
        # 4) upsert (preserve existing if present)
        record = model.where(
          supplier_id:  safe["supplier_id"],
          subsystem_id: safe["subsystem_id"]
        ).first_or_initialize
    
        record.assign_attributes(safe)
        record.save!
      end
    
      head :no_content
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end


      subsystem = Subsystem.find(saved_records.first[:subsystem_id])

      # Create one notification summarizing all the tables just saved
      Notification.create!(
        title:             "Multiple Tables Submitted",
        body:              "Supplier #{supplier.supplier_name} submitted data for #{subsystem.name}.",
        notifiable:        supplier,
        read:              false,
        status:            "new",
        notification_type: "evaluation",
        additional_data:   saved_records.to_json
      )

      render json: { message: "All tables saved." }, status: :created
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :bad_request
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
      payload      = params.require(:data).permit!
      subsystem_id = payload.delete("subsystem_id") || payload.delete(:subsystem_id)
      model        = table_name.classify.constantize

      record = model.where(supplier_id: supplier.id, subsystem_id: subsystem_id)
                    .first_or_initialize

      record.assign_attributes(payload)
      record.supplier_id  = supplier.id
      record.subsystem_id = subsystem_id

      if record.save
        subsystem = Subsystem.find(subsystem_id)

        # Create a notification for this one table
        Notification.create!(
          title:             "New Submission: #{table_name.titleize}",
          body:              "Supplier #{supplier.supplier_name} submitted data for #{subsystem.name}.",
          notifiable:        supplier,
          read:              false,
          status:            "new",
          notification_type: "evaluation",
          additional_data:   {
                                table:        table_name,
                                record_id:    record.id,
                                subsystem_id: subsystem_id
                              }.to_json
        )

        render json: { message: "Data for #{table_name} saved." }, status: :created
      else
        render json: { error: record.errors.full_messages }, status: :unprocessable_entity
      end
    rescue NameError
      render json: { error: "Invalid table: #{table_name}" }, status: :bad_request
    end

    # … your existing index, update and table_metadata actions unchanged …

    private

    def authenticate_supplier!
      token = request.headers['Authorization']&.split(' ')&.last
      return unless token

      payload = JWT.decode(
        token,
        Rails.application.secret_key_base,
        true,
        algorithm: 'HS256'
      ).first

      ::Supplier.find_by(id: payload['sub'])
    rescue
      nil
    end
  end
end
