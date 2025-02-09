class AddSupplierIdToIsolations < ActiveRecord::Migration[7.1]
  def change
    add_reference :isolations, :supplier, null: false, foreign_key: true
  end
end
