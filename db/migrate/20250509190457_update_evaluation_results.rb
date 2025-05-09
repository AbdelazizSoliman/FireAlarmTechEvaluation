class UpdateEvaluationResults < ActiveRecord::Migration[7.1]
  def change
    change_table :evaluation_results do |t|
      # Remove the old column
      t.remove :score

      # Add new columns
      t.decimal :submitted_value, precision: 12, scale: 4
      t.decimal :standard_value, precision: 12, scale: 4
      t.decimal :tolerance, precision: 5, scale: 2
      t.decimal :degree, precision: 3, scale: 1
      t.string :status
    end
  end
end
