class AddSupplierIdToDoorHolders < ActiveRecord::Migration[7.1]
  def change
    add_reference :door_holders, :supplier, null: false, foreign_key: true
  end
end
