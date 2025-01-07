class AddPasswordToSuppliers < ActiveRecord::Migration[7.1]
  def change
    add_column :suppliers, :encrypted_password, :string
    add_column :suppliers, :reset_password_token, :string
    add_column :suppliers, :reset_password_sent_at, :datetime
  end
end
