class AddPasswordDigestToSuppliers < ActiveRecord::Migration[7.1]
  def change
    add_column :suppliers, :password_digest, :string
  end
end
