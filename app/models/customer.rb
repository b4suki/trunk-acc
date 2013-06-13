# == Schema Information
# Schema version: 20081030064618
#
# Table name: customers
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  description :text
#  address     :text
#  phone       :string(255)
#  fax         :string(255)
#  cantact     :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Customer < ActiveRecord::Base
  acts_as_activity_logged :delay_after_create => 5.seconds
  
  has_many :accounting_sale_balances
  has_many :tax_credits
  
  validates_presence_of :name, :phone, :fax
  validates_numericality_of :phone, :fax
  validates_uniqueness_of :name
end
