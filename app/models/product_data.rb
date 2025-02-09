class ProductData < ApplicationRecord
  belongs_to :subsystem
  belongs_to :supplier

  # validates :manufacturer, :submitted_product, :product_certifications, :total_years_in_saudi_market, :coo, presence: true
end
