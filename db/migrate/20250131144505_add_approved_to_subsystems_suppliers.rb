class AddApprovedToSubsystemsSuppliers < ActiveRecord::Migration[7.1]
  def change
    add_column :subsystems_suppliers, :approved, :boolean, default: false, null: false
  end
end
