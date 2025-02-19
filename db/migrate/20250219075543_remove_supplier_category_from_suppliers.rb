class RemoveSupplierCategoryFromSuppliers < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:suppliers, :supplier_category)
      remove_column :suppliers, :supplier_category, :string
    end
  end
end
