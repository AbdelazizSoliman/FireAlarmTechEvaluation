class AddSupplierIdToGeneralCommercialData < ActiveRecord::Migration[7.1]
  def change
    add_reference :general_commercial_data, :supplier, null: false, foreign_key: true
  end
end
