class CreateJoinTableProjectScopesSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_join_table :project_scopes, :suppliers do |t|
      t.index [:project_scope_id, :supplier_id]
      t.index [:supplier_id, :project_scope_id]
    end
  end
end
