class DetailPulsaCustomer < ActiveRecord::Base
  belongs_to :item
  belongs_to :pulsa_customer
end
