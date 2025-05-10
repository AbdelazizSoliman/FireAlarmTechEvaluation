class AddComboFieldsToEvaluationResults < ActiveRecord::Migration[7.1]
  def change
    add_column :evaluation_results, :combo_case, :string
    add_column :evaluation_results, :combo_logic, :string
  end
end
