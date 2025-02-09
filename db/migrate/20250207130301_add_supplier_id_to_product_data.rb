class AddSupplierIdToProductData < ActiveRecord::Migration[7.1]
  def change
    add_reference :product_data, :supplier, null: false, foreign_key: true
  end
end
