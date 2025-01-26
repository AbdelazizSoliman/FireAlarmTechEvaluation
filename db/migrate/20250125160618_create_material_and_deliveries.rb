class CreateMaterialAndDeliveries < ActiveRecord::Migration[7.1]
  def change
    create_table :material_and_deliveries do |t|
      t.string :material_availability
      t.string :delivery_time_period
      t.string :delivery_type
      t.string :delivery_to
      t.references :subsystem, null: false, foreign_key: true

      t.timestamps
    end
  end
end
