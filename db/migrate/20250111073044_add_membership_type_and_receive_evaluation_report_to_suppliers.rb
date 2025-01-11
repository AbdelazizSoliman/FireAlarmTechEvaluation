class AddMembershipTypeAndReceiveEvaluationReportToSuppliers < ActiveRecord::Migration[7.1]
  def change
    add_column :suppliers, :membership_type, :string
    add_column :suppliers, :receive_evaluation_report, :boolean
  end
end
