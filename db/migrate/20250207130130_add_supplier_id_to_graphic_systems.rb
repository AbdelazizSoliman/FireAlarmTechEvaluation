class AddSupplierIdToGraphicSystems < ActiveRecord::Migration[7.1]
  def change
    add_reference :graphic_systems, :supplier, null: false, foreign_key: true
  end
end
