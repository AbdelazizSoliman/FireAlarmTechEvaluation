class AddCertificationsToTestDynamically < ActiveRecord::Migration[7.1]
  def change
    add_column :test_dynamically, :certifications, :string
  end
end
