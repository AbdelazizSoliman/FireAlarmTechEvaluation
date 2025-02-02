class RemoveMembershipTypeFromSuppliers < ActiveRecord::Migration[7.1]
  def change
    remove_column :suppliers, :membership_type, :string
  end
end
