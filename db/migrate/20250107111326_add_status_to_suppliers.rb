class AddStatusToSuppliers < ActiveRecord::Migration[7.1]
  def change
    add_column :suppliers, :status, :string, default: 'pending'
  end
end
