class AddProjectScopeToSystems < ActiveRecord::Migration[7.1]
  def change
    add_reference :systems, :project_scope, null: false, foreign_key: true
  end
end
