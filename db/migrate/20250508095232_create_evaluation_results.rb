class CreateEvaluationResults < ActiveRecord::Migration[7.1]
  def change
    create_table :evaluation_results do |t|
      t.string     :table_name,  null: false
      t.string     :column_name, null: false
      t.decimal    :score,       precision: 12, scale: 4, null: false

      # If you have Supplier and Subsystem models and want FKs:
      t.references :supplier,    null: false, foreign_key: true, type: :bigint
      t.references :subsystem,   null: false, foreign_key: true, type: :bigint

      t.timestamps
    end
  end
end
