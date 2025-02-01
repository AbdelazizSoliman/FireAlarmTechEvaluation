class RemoveSubsystemsFromSuppliers < ActiveRecord::Migration[7.1]
  def change
    remove_column :suppliers, :subsystems, :text
  end
end
