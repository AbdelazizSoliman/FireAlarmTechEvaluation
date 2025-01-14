class AddIndexesToProjectsSuppliers < ActiveRecord::Migration[7.1]
  def change
    add_index :projects_suppliers, [:project_id, :supplier_id], unique: true
    add_index :projects_suppliers, [:supplier_id, :project_id]
  end
end
