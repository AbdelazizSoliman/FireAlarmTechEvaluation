class CreateSupplierData < ActiveRecord::Migration[7.0]
  def change
    create_table :supplier_data do |t|
      t.string :supplier_name, null: false, comment: "The name of the supplier"
      t.string :supplier_category, null: false, comment: "The category or type of the supplier"
      t.integer :total_years_in_saudi_market, null: false, comment: "The total number of years the supplier has been active in the Saudi market"
      t.text :similar_projects, comment: "Details of similar projects carried out (mention 3 projects)"
      
      t.timestamps
    end
  end
end
