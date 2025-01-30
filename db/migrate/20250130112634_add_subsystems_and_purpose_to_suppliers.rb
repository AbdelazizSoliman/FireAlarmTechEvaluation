class AddSubsystemsAndPurposeToSuppliers < ActiveRecord::Migration[7.1]
  def change
    add_column :suppliers, :subsystems, :text
    add_column :suppliers, :purpose, :string
  end
end
