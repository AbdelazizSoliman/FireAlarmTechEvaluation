class AddSubsystemIdToSupplierData < ActiveRecord::Migration[7.0]
  def change
    add_reference :supplier_data, :subsystem, null: false, foreign_key: true
  end
end
