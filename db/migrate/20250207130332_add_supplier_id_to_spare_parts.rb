class AddSupplierIdToSpareParts < ActiveRecord::Migration[7.1]
  def change
    add_reference :spare_parts, :supplier, null: false, foreign_key: true
  end
end
