class CreateGeneralCommercialData < ActiveRecord::Migration[7.1]
  def change
    create_table :general_commercial_data do |t|
      t.integer :warranty_for_materials
      t.integer :warranty_for_configuration_programming
      t.integer :support_and_maintenance
      t.integer :spare_parts_availability
      t.integer :advanced_payment_minimum
      t.integer :performance_bond
      t.decimal :total_price_excluding_vat
      t.references :subsystem, null: false, foreign_key: true

      t.timestamps
    end
  end
end
