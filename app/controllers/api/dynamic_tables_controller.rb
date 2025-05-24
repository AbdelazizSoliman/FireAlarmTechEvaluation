module Api
  class DynamicTablesController < ApplicationController
    skip_forgery_protection

    # GET /api/subsystems/:subsystem_id/table_order
    def table_order
      order = TableDefinition
                .where(subsystem_id: params[:subsystem_id])
                .order(:position)
                .pluck(:table_name)

      render json: { order: order }
    end

    # GET /api/subsystems/:subsystem_id/table_definitions
    def table_definitions
      defs = TableDefinition
               .where(subsystem_id: params[:subsystem_id])
               .order(:position)
               .pluck(:table_name, :parent_table, :position)
               .map { |t, p, pos| { table_name: t, parent_table: p, position: pos } }

      render json: defs
    end

    # POST /api/subsystems/:subsystem_id/save_all
    def save_all
      supplier     = authenticate_supplier!
      return head(:unauthorized) unless supplier

      subsystem_id = params[:subsystem_id]
      payloads     = params.require(:data).to_unsafe_h

      table_defs = TableDefinition
                     .where(subsystem_id: subsystem_id)
                     .order(Arel.sql("COALESCE(parent_table,'') ASC, position ASC"))

      saved = []
      table_defs.each do |td|
        tn = td.table_name
        next unless payloads.key?(tn)

        raw   = payloads[tn] || {}
        model = Class.new(ActiveRecord::Base) do
          self.table_name        = tn
          self.inheritance_column = :_type_disabled
        end

        allowed = model.column_names
        safe    = raw.slice(*allowed)
                     .except("id", "created_at", "updated_at", "supplier_id", "subsystem_id")

        if td.parent_table.present?
          parent = Class.new(ActiveRecord::Base) do
            self.table_name        = td.parent_table
            self.inheritance_column = :_type_disabled
          end.find_by(
            supplier_id:  supplier.id,
            subsystem_id: subsystem_id
          )
          safe["parent_id"] = parent.id if parent
        end

        record = model
                   .where(supplier_id:  supplier.id,
                          subsystem_id: subsystem_id)
                   .first_or_initialize

        record.assign_attributes(safe)
        record.supplier_id  = supplier.id
        record.subsystem_id = subsystem_id
        record.save!

        saved << { table: tn, record_id: record.id }
      end

      if saved.any?
        subsystem = ::Subsystem.find(subsystem_id)
        Notification.create!(
          title:             "Multiple Tables Submitted",
          body:              "Supplier #{supplier.supplier_name} submitted data for #{subsystem.name}.",
          notifiable:        supplier,
          read:              false,
          status:            "new",
          notification_type: "evaluation",
          additional_data:   saved.to_json
        )
      end

      render json: { message: "All tables saved.", saved: saved }, status: :created

    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :bad_request
    rescue ActiveRecord::RecordInvalid    => e
      render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    def submitted_data
      supplier = authenticate_supplier!
      subsystem_id = params[:id] || params[:subsystem_id]

      if supplier.nil?
        render json: { error: 'Supplier not found. Please log in again.' }, status: :unauthorized
        return
      end

      # Fetch all table definitions for this subsystem
      tables = TableDefinition.where(subsystem_id: subsystem_id)
      data = {}

      tables.each do |td|
        model = Class.new(ActiveRecord::Base) do
          self.table_name = td.table_name
          self.inheritance_column = :_type_disabled
        end

        # For each table, get the one record for this supplier and subsystem
        record = model.find_by(supplier_id: supplier.id, subsystem_id: subsystem_id)
        data[td.table_name] = record ? record.attributes : nil
      end

      render json: { submission: data }, status: :ok
    end

    def my_submissions
      supplier = authenticate_supplier!
      return render json: { error: "Unauthorized" }, status: :unauthorized unless supplier

      # Get all unique subsystem_ids where the supplier has submitted data
      submitted_subsystem_ids = TableDefinition.joins("LEFT JOIN (#{dynamic_table_query(supplier.id)}) dt ON dt.subsystem_id = table_definitions.subsystem_id")
                                              .where("dt.supplier_id = ?", supplier.id)
                                              .distinct
                                              .pluck(:subsystem_id)

      submitted = []
      submitted_subsystem_ids.each do |subsystem_id|
        subsystem = Subsystem.find_by(id: subsystem_id)
        if subsystem
          submitted << {
            subsystem_id: subsystem.id,
            subsystem_name: subsystem.name
          }
        end
      end

      render json: { submissions: submitted }
    end

    # GET /api/table_metadata/:table_name?subsystem_id=…
    def table_metadata
      tn        = params[:table_name]
      table_def = TableDefinition.find_by!(table_name: tn)

      meta = ColumnMetadata
               .where(table_name: tn)
               .each_with_object({}) do |m,h|
                 opts     = m.options || {}
                 raw_vals = opts["allowed_values"]
                 # ensure allowed_values is always an Array
                 allowed = if raw_vals.is_a?(Array)
                             raw_vals
                           elsif raw_vals.is_a?(String)
                             raw_vals.split(",").map(&:strip)
                           else
                             []
                           end

                 # combo_standards should also default to a hash
                 combo = opts["combo_standards"].is_a?(Hash) ? opts["combo_standards"] : {}

                 h[m.column_name] = {
                   feature:   m.feature,
                   options:   opts.merge(
                                "allowed_values"   => allowed,
                                "combo_standards"  => combo
                              ),
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

    private

    def authenticate_supplier!
      token = request.headers['Authorization']&.split(' ')&.last
      return unless token

      payload, = JWT.decode(
        token,
        Rails.application.secret_key_base,
        true,
        algorithms: ['HS256']
      )
      ::Supplier.find_by(id: payload['sub'])
    rescue JWT::DecodeError
      nil
    end

    def dynamic_table_query(supplier_id)
      table_names = TableDefinition.pluck(:table_name).map { |tn| "\"#{tn}\"" }.join(", ")
      <<-SQL
        SELECT DISTINCT subsystem_id, supplier_id
        FROM (#{table_names.map { |tn| "SELECT subsystem_id, supplier_id FROM #{tn}" }.join(" UNION ALL ")})
        WHERE supplier_id = #{supplier_id}
      SQL
    end
  end
end