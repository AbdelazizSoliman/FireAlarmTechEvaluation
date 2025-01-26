class CreateTelephoneSystems < ActiveRecord::Migration[7.1]
  def change
    create_table :telephone_systems do |t|
      t.integer :number_of_firefighter_telephone_circuits_per_panel
      t.integer :total_no_of_firefighter_telephone_cabinet
      t.integer :total_no_of_firefighter_phones
      t.integer :total_no_of_firefighter_jacks
      t.references :subsystem, null: false, foreign_key: true

      t.timestamps
    end
  end
end
