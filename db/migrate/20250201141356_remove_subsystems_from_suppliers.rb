class RemoveSubsystemsFromSuppliers < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:suppliers, :subsystems)
      remove_column :suppliers, :subsystems, :text
    end
  end
end
