class Product < ActiveRecord::Base
  belongs_to :item
  belongs_to :prototype_item
  has_many :product_details
  has_many :trans_items
end
