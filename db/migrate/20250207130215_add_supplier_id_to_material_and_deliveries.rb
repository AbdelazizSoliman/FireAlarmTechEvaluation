class AddSupplierIdToMaterialAndDeliveries < ActiveRecord::Migration[7.1]
  def change
    add_reference :material_and_deliveries, :supplier, null: false, foreign_key: true
  end
end
