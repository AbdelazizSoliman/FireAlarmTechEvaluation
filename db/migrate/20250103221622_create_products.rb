class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :product_name
      t.string :country_of_origin
      t.string :country_of_manufacture_mfacp
      t.string :country_of_manufacture_detectors

      t.timestamps
    end
  end
end
