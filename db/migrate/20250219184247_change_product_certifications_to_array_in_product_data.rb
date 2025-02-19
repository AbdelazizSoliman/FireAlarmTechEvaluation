class ChangeProductCertificationsToArrayInProductData < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL.squish
      ALTER TABLE product_data
      ALTER COLUMN product_certifications TYPE text[]
      USING (
        CASE 
          WHEN product_certifications IS NULL OR product_certifications = ''
          THEN '{}'::text[]
          ELSE ('{' || product_certifications || '}')::text[]
        END
      );
    SQL
    change_column_default :product_data, :product_certifications, []
  end

  def down
    change_column :product_data, :product_certifications, :string, default: nil
  end
end
