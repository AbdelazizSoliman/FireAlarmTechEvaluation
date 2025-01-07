class RemoveEncryptedPasswordFromSuppliers < ActiveRecord::Migration[7.1]
  def change
    remove_column :suppliers, :encrypted_password, :string
  end
end
