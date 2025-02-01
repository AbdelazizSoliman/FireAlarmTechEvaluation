class CreateSystemsSuppliersJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_table :systems_suppliers, id: false do |t|
      t.bigint :system_id, null: false
      t.bigint :supplier_id, null: false

      t.index [:system_id, :supplier_id], unique: true
      t.index [:supplier_id, :system_id]
    end

    add_foreign_key :systems_suppliers, :systems
    add_foreign_key :systems_suppliers, :suppliers
  end
end
