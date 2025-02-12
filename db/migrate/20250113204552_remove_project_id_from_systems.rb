class RemoveProjectIdFromSystems < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:systems, :project_id)
      remove_column :systems, :project_id, :bigint
    end
  end
end
