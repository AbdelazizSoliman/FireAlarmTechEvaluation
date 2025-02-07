class AddSupplierIdToScopeOfWorks < ActiveRecord::Migration[7.1]
  def change
    add_reference :scope_of_works, :supplier, null: false, foreign_key: true
  end
end
