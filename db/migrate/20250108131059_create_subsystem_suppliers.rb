class CreateSubsystemSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :subsystem_suppliers do |t|
      t.references :subsystem, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true

      t.timestamps
    end
  end
end
