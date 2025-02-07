class AddSupplierIdToEvacuationSystems < ActiveRecord::Migration[7.1]
  def change
    add_reference :evacuation_systems, :supplier, null: false, foreign_key: true
  end
end
