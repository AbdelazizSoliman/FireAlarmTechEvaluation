# app/controllers/api/dynamic_tables_controller.rb
module Api
  class DynamicTablesController < ApplicationController
    # we’re handling our own CSRF via token header
    skip_forgery_protection

    # GET  /api/subsystems/:subsystem_id/table_order
    def table_order
      order = TableDefinition.where(subsystem_id: params[:subsystem_id])
                             .order(:position)
                             .pluck(:table_name)
      render json: { order: order }
    end

    # GET  /api/subsystems/:subsystem_id/table_definitions
    def table_definitions
      defs = TableDefinition.where(subsystem_id: params[:subsystem_id])
                            .order(:position)
                            .pluck(:table_name, :parent_table, :position)
                            .map { |t,p,pos|
                              { table_name: t, parent_table: p, position: pos }
                            }
      render json: defs
    end

    # POST /api/save_all?subsystem_id=…
    def save_all
      payloads = params.require(:data).to_unsafe_h
      subsystem_id = params[:subsystem_id]

      # fetch in parents‐first order
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

        # only real columns
        allowed = model.column_names
        safe    = raw.slice(*allowed)
                     .except("id","created_at","updated_at","supplier_id","subsystem_id")

        # wire parent_id for subtables
        if td.parent_table.present?
          parent_model = Class.new(ActiveRecord::Base) do
            self.table_name        = td.parent_table
            self.inheritance_column = :_type_disabled
          end
          parent = parent_model.find_by(
            supplier_id:  raw["supplier_id"],
            subsystem_id: raw["subsystem_id"]
          )
          safe["parent_id"] = parent.id if parent
        end

        # upsert by supplier+subsystem
        record = model.where(
                   supplier_id:  raw["supplier_id"],
                   subsystem_id: raw["subsystem_id"]
                 ).first_or_initialize

        record.assign_attributes(safe)
        record.save!
        saved << { table: tn, record_id: record.id }
      end

      # single notification
      if saved.any?
        first = saved.first
        supplier  = Supplier.find(params.dig(:data, first[:table], "supplier_id"))
        subsystem = Subsystem.find(params[:subsystem_id])

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
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    # GET /api/table_metadata/:table_name?subsystem_id=…
    def table_metadata
      tn        = params[:table_name]
      table_def = TableDefinition.find_by!(table_name: tn)
      meta = ColumnMetadata.where(table_name: tn).each_with_object({}) do |m, h|
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

    # other actions (index/update/save_data) unchanged…

    private

    # optional: implement authenticate_supplier! if you use save_data…
  end
end
