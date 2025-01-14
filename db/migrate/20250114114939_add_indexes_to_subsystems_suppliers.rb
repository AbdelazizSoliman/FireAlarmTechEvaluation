class AddIndexesToSubsystemsSuppliers < ActiveRecord::Migration[7.1]
  def change
    add_index :subsystems_suppliers, [:subsystem_id, :supplier_id], unique: true
    add_index :subsystems_suppliers, [:supplier_id, :subsystem_id]
  end
end
