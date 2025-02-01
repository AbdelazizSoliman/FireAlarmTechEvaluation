class AddApprovedToSystemsSuppliers < ActiveRecord::Migration[7.1]
  def change
    add_column :systems_suppliers, :approved, :boolean, default: false, null: false
  end
end
