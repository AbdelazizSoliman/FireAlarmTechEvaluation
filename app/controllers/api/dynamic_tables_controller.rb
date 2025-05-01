# app/controllers/api/dynamic_tables_controller.rb
module Api
  class DynamicTablesController < ApplicationController
    skip_forgery_protection

    # POST /api/save_all
    def save_all
      supplier = authenticate_supplier!
      return render json: { error: "Unauthorized" }, status: :unauthorized unless supplier

      all_payloads  = params.require(:data).permit!.to_h
      saved_records = []

      all_payloads.each do |table_name, payload|
        unless ActiveRecord::Base.connection.table_exists?(table_name)
          return render json: { error: "Table #{table_name} not found" },
                        status: :bad_request
        end

        model = Class.new(ActiveRecord::Base) do
          self.table_name        = table_name
          self.inheritance_column = :_type_disabled
        end

        p            = payload.to_h
        subsystem_id = p.delete("subsystem_id") || p.delete(:subsystem_id)
        safe_attrs   = p.except("id", "created_at", "updated_at", "supplier_id")

        record = model.where(supplier_id: supplier.id, subsystem_id: subsystem_id)
                      .first_or_initialize

        record.assign_attributes(safe_attrs)
        record.supplier_id  = supplier.id
        record.subsystem_id = subsystem_id
        record.save!

        saved_records << {
          table:        table_name,
          record_id:    record.id,
          subsystem_id: subsystem_id
        }
      end

      # Create one notification summarizing all the tables just saved
      Notification.create!(
        title:             "Multiple Tables Submitted",
        body:              "Supplier #{supplier.supplier_name} submitted data for #{saved_records.size} tables.",
        notifiable:        supplier,
        read:              false,
        status:            "new",
        notification_type: "submission",
        additional_data:   saved_records.to_json
      )

      render json: { message: "All tables saved." }, status: :created
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :bad_request
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
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
        # Create a notification for this one table
        Notification.create!(
          title:             "New Submission: #{table_name.titleize}",
          body:              "Supplier #{supplier.supplier_name} submitted #{table_name.titleize}.",
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
