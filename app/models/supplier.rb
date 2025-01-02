class Supplier < ApplicationRecord
    has_many :project, dependent: :destroy
   
    
    # accepts_nested_attributes_for :sites, allow_destroy: true, reject_if: :all_blank
    accepts_nested_attributes_for :project
 
 
    # Validates the presence
   validates  :supplier_name,:supplier_category,:total_years_in_saudi_market,:phone,:supplier_email, presence: true
 
 #   # Validates the format of the phone number
 #   validates :phone, :bill_to_phone,
 #               format: { with: /\A\d{10}\z/, message: 'must be exactly 10 digits' }
 
   # Validates the format of the email
   validates :supplier_email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'must be a valid email address' }
 
 end
