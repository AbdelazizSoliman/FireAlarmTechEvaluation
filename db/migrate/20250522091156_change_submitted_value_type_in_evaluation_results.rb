class ChangeSubmittedValueTypeInEvaluationResults < ActiveRecord::Migration[7.1]
  def up
    # For existing numeric data, cast:
    change_column :evaluation_results, :submitted_value, :text, using: 'submitted_value::text'
  end

  def down
    change_column :evaluation_results, :submitted_value, :float, using: 'submitted_value::float'
  end
end
