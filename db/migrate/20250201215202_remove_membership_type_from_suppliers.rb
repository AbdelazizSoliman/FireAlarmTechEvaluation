class RemoveMembershipTypeFromSuppliers < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:suppliers, :membership_type)
      remove_column :suppliers, :membership_type, :string
    end
  end
end
