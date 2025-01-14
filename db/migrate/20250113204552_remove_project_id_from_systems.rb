class RemoveProjectIdFromSystems < ActiveRecord::Migration[7.1]
  def change
    remove_column :systems, :project_id, :bigint
  end
end
