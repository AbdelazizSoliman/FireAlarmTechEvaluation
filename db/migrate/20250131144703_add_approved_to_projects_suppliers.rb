class AddApprovedToProjectsSuppliers < ActiveRecord::Migration[7.1]
  def change
    add_column :projects_suppliers, :approved, :boolean, default: false, null: false
  end
end
