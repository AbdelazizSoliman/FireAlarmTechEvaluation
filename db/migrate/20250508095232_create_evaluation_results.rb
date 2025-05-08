class CreateEvaluationResults < ActiveRecord::Migration[7.1]
  def change
    create_table :evaluation_results do |t|
      t.references :supplier, required: true, null: false, foreign_key: true
      t.references :column_metadata, required: true, null: false, foreign_key: true
      t.decimal :degree, precision: 5, scale: 2
      t.string :status

      t.timestamps
    end
  end
end
