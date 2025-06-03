module Api
  class SubTablesController < Api::ApplicationController
    skip_before_action :verify_authenticity_token

    def index
      parent_table = params[:parent_table]
      subsystem_id = params[:subsystemId]

      if parent_table.blank? || subsystem_id.blank?
        return render json: { error: "Missing parent_table or subsystemId parameter" }, status: :bad_request
      end

      # Fetch all TableDefinition records that have a non-null parent_table equal to the provided parent_table
      # and belong to the given subsystem.
      sub_tables = TableDefinition.where(subsystem_id: subsystem_id)
                                  .where.not(parent_table: nil)
                                  .where(parent_table: parent_table)
                                  .order(:position)

      render json: sub_tables.as_json(only: [:id, :table_name, :parent_table, :position])
    end
  end
end
