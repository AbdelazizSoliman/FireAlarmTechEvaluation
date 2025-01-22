class CreateProductData < ActiveRecord::Migration[7.1]
  def change
    create_table :product_data do |t|
      t.string :manufacturer
      t.string :submitted_product
      t.string :product_certifications
      t.integer :total_years_in_saudi_market
      t.string :coo
      t.string :com_for_mfacp
      t.string :com_for_detectors
      t.references :subsystem, null: false, foreign_key: true

      t.timestamps
    end
  end
end
