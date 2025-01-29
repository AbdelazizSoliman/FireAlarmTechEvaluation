class AddRegistrationAndEvaluationTypesToSuppliers < ActiveRecord::Migration[7.1]
  def change
    add_column :suppliers, :registration_type, :string, null: false, default: "evaluation"
    add_column :suppliers, :evaluation_type, :string, default: nil
  end
end
