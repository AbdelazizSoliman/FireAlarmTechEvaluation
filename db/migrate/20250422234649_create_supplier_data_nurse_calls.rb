class CreateSupplierDataNurseCalls < ActiveRecord::Migration[7.1]
  def change
    create_table :supplier_data_nurse_calls do |t|
      t.bigint :subsystem_id
      t.bigint :supplier_id
      t.string :supplier_name
      t.string :supplier_category
      t.integer :total_years_in_saudi_market

      t.timestamps
    end
  end
end
