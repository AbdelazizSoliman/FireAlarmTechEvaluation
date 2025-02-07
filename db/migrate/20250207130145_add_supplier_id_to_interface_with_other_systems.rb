class AddSupplierIdToInterfaceWithOtherSystems < ActiveRecord::Migration[7.1]
  def change
    add_reference :interface_with_other_systems, :supplier, null: false, foreign_key: true
  end
end
