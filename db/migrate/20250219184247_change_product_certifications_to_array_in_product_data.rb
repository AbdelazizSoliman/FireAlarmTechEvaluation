class ChangeProductCertificationsToArrayInProductData < ActiveRecord::Migration[7.1]
  def up
    change_column :product_data, :product_certifications, :text, array: true, default: []
  end

  def down
    change_column :product_data, :product_certifications, :string, default: nil
  end
end
