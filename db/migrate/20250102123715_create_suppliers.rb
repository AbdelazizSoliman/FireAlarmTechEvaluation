class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :supplier_name
      t.string :supplier_category
      t.integer :total_years_in_saudi_market
      t.string :phone
      t.string :supplier_email

      t.timestamps
    end
  end
end
