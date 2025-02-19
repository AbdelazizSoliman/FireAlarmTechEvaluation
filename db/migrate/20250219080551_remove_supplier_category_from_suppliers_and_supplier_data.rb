class RemoveSupplierCategoryFromSuppliersAndSupplierData < ActiveRecord::Migration[7.1]
  def change
    # Remove supplier_category from suppliers table if it exists
    if column_exists?(:suppliers, :supplier_category)
      remove_column :suppliers, :supplier_category, :string
    end

    # Remove supplier_category from supplier_data table if it exists
    if column_exists?(:supplier_data, :supplier_category)
      remove_column :supplier_data, :supplier_category, :string
    end
  end
end
