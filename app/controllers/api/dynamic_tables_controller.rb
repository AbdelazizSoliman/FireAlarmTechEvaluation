# app/controllers/api/dynamic_tables_controller.rb
module Api
  class DynamicTablesController < ApplicationController
    skip_forgery_protection

    # GET  /api/subsystems/:subsystem_id/table_definitions
    def table_definitions
      defs = TableDefinition
               .where(subsystem_id: params[:subsystem_id])
               .order(:position)
               .pluck(:table_name, :parent_table, :position)
               .map { |name, parent, pos|
                 { table_name: name, parent_table: parent, position: pos }
               }
      render json: defs
    end

    # POST /api/save_all
    def save_all
      payloads = params.require(:data).to_unsafe_h

      table_defs = TableDefinition
                     .where(subsystem_id: params[:subsystem_id])
                     .order(Arel.sql("COALESCE(parent_table, '') ASC, position ASC"))

      saved_records = []

      table_defs.each do |td|
        name  = td.table_name
        next unless payloads.key?(name)

        raw   = payloads[name] || {}
        model = Class.new(ActiveRecord::Base) do
          self.table_name        = name
          self.inheritance_column = :_type_disabled
        end

        # strip out anything not a real column
        allowed = model.column_names
        safe    = raw.slice(*allowed)
                     .except("id","created_at","updated_at","supplier_id","subsystem_id")

        # wire up parent_id if this is a child table
        if td.parent_table.present?
          parent_model = Class.new(ActiveRecord::Base) do
            self.table_name        = td.parent_table
            self.inheritance_column = :_type_disabled
          end

          parent = parent_model.find_by(
            supplier_id:  safe["supplier_id"],
            subsystem_id: safe["subsystem_id"]
          )
          safe["parent_id"] = parent.id if parent
        end

        # upsert by supplier+subsystem
        record = model
                   .where(supplier_id:  safe["supplier_id"],
                          subsystem_id: safe["subsystem_id"])
                   .first_or_initialize

        record.assign_attributes(safe)
        record.save!

        saved_records << {
          table_name:    name,
          supplier_id:   safe["supplier_id"],
          subsystem_id:  safe["subsystem_id"],
          record_id:     record.id
        }
      end

      # send a single notification for the whole batch
      if saved_records.any?
        first = saved_records.first
        supplier  = Supplier.find(first[:supplier_id])
        subsystem = Subsystem.find(first[:subsystem_id])

        Notification.create!(
          title:             "Multiple Tables Submitted",
          body:              "Supplier #{supplier.supplier_name} submitted data for #{subsystem.name}.",
          notifiable:        supplier,
          read:              false,
          status:            "new",
          notification_type: "evaluation",
          additional_data:   saved_records.to_json
        )
      end

      render json: { message: "All tables saved.", saved: saved_records }, status: :created

    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :bad_request

    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    # GET /api/dynamic_tables/:table_name
    def index
      table_def = TableDefinition.find_by!(table_name: params[:table_name])
      is_static = table_def.static?

      columns = ActiveRecord::Base.connection.columns(params[:table_name]).map(&:name)
      records = ActiveRecord::Base.connection
                   .execute("SELECT * FROM #{params[:table_name]}")
                   .to_a

      render json: { columns: columns, data: records, static: is_static }
    end

    # PATCH /api/dynamic_tables/:table_name/:id
    def update
      table_name  = params[:table_name]
      record_id   = params[:id]
      update_p    = params.except(:table_name, :id, :controller, :action)

      set_clause = update_p.map do |k,v|
        "#{k} = #{ActiveRecord::Base.connection.quote(v)}"
      end.join(", ")

      sql = <<~SQL
        UPDATE #{table_name}
           SET #{set_clause}
         WHERE id = #{record_id}
      SQL

      ActiveRecord::Base.connection.execute(sql)
      render json: { message: 'Record updated successfully!' }
    end

    # GET /api/table_metadata/:table_name
    def table_metadata
      table_name = params[:table_name]
      table_def  = TableDefinition.find_by!(table_name: table_name)

      meta = ColumnMetadata
               .where(table_name: table_name)
               .each_with_object({}) do |m,h|
                 h[m.column_name] = {
                   feature:   m.feature,
                   options:   m.options,
                   row:       m.row,
                   col:       m.col,
                   label_row: m.label_row,
                   label_col: m.label_col
                 }
               end

      render json: {
        columns:  meta.keys,
        metadata: meta,
        static:   table_def.static?
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
      render json: { error: "Invalid table: #{params[:table_name]}" }, status: :bad_request
    end

    private

    def authenticate_supplier!
      token = request.headers['Authorization']&.split(' ')&.last
      payload = JWT.decode(
        token,
        Rails.application.secret_key_base,
        true,
        algorithm: 'HS256'
      ).first
      Supplier.find_by(id: payload['sub'])
    rescue
      nil
    end
  end
end
