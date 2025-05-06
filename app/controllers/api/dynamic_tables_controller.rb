# app/controllers/api/dynamic_tables_controller.rb
module Api
  class DynamicTablesController < ApplicationController
    skip_forgery_protection
    before_action :authenticate_supplier!, only: [:save_all]

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
               .map { |name, parent, pos|
                 { table_name: name, parent_table: parent, position: pos }
               }
      render json: defs
    end

    # POST /api/subsystems/:subsystem_id/save_all
    def save_all
      subsystem_id = params[:subsystem_id]
      payloads     = params.require(:data).to_unsafe_h

      table_defs = TableDefinition
                     .where(subsystem_id: subsystem_id)
                     .order(Arel.sql("COALESCE(parent_table, '') ASC, position ASC"))

      saved = []

      table_defs.each do |td|
        tn = td.table_name
        next unless payloads.key?(tn)

        raw = payloads[tn] || {}
        model = Class.new(ActiveRecord::Base) do
          self.table_name        = tn
          self.inheritance_column = :_type_disabled
        end

        allowed = model.column_names
        safe    = raw.slice(*allowed)
                     .except("id", "created_at", "updated_at", "supplier_id", "subsystem_id")

        if td.parent_table.present?
          parent_model = Class.new(ActiveRecord::Base) do
            self.table_name        = td.parent_table
            self.inheritance_column = :_type_disabled
          end
          parent = parent_model.find_by(
            supplier_id:  current_supplier.id,
            subsystem_id: subsystem_id
          )
          safe["parent_id"] = parent.id if parent
        end

        record = model
                   .where(supplier_id:  current_supplier.id,
                          subsystem_id: subsystem_id)
                   .first_or_initialize

        record.assign_attributes(safe)
        record.supplier_id  = current_supplier.id
        record.subsystem_id = subsystem_id
        record.save!

        saved << { table: tn, record_id: record.id }
      end

      render json: { message: "All tables saved.", saved: saved }, status: :created
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :bad_request
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    # GET /api/table_metadata/:table_name
    def table_metadata
      tn        = params[:table_name]
      table_def = TableDefinition.find_by!(table_name: tn)

      meta = ColumnMetadata
               .where(table_name: tn)
               .each_with_object({}) do |m, h|
                 h[m.column_name] = {
                   feature:   m.feature,
                   options:   m.options,
                   row:       m.row,
                   col:       m.col,
                   label_row: m.label_row,
                   label_col: m.label_col
                 }
               end

      render json: { metadata: meta, static: table_def.static? }
    end

    private

    # Decode JWT and set @current_supplier
    def authenticate_supplier!
      auth_header = request.headers["Authorization"]
      return head(:unauthorized) unless auth_header&.start_with?("Bearer ")

      token = auth_header.split(" ").last
      payload, = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256")
      @current_supplier = Supplier.find_by(id: payload["sub"])
      head(:unauthorized) unless @current_supplier
    rescue JWT::DecodeError
      head(:unauthorized)
    end

    def current_supplier
      @current_supplier
    end
  end
end
