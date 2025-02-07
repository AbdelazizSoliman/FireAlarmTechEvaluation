class AddSupplierIdToConnectionBetweens < ActiveRecord::Migration[7.1]
  def change
    add_reference :connection_betweens, :supplier, null: false, foreign_key: true
    add_index :connection_betweens, [:supplier_id, :subsystem_id], unique: true, name: 'idx_connection_betweens_sup_sub'
  end
end
