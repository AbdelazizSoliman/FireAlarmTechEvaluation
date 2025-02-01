class AddApprovedToProjectScopesSuppliers < ActiveRecord::Migration[7.1]
  def change
    add_column :project_scopes_suppliers, :approved, :boolean, default: false, null: false
  end
end
