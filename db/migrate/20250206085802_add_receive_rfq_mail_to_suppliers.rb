class AddReceiveRfqMailToSuppliers < ActiveRecord::Migration[7.1]
  def change
    add_column :suppliers, :receive_rfq_mail, :boolean, default: false, null: false  end
end
