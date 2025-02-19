class RenameRegistrationTypeAndAddSupplierCategory < ActiveRecord::Migration[7.1]
  def change
    # Rename registration_type to supplier_category in suppliers table
    if column_exists?(:suppliers, :registration_type)
      rename_column :suppliers, :registration_type, :supplier_category
    end

    # Add supplier_category to supplier_data table (temporarily allowing null values)
    unless column_exists?(:supplier_data, :supplier_category)
      add_column :supplier_data, :supplier_category, :string, default: "Uncategorized"
    end

    # Ensure no null values exist (set to a default category)
    SupplierData.where(supplier_category: nil).update_all(supplier_category: "Uncategorized")

    # Now enforce NOT NULL constraint
    change_column_null :supplier_data, :supplier_category, false
  end
end
