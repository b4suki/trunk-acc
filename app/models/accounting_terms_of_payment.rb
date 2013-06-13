class AccountingTermsOfPayment < ActiveRecord::Base
  has_many :accounting_purchase_balances, :foreign_key => 'terms_of_payment_id'
  has_many :accounting_sale_balances, :foreign_key => 'terms_of_payment_id'
  validates_numericality_of :days
  validates_presence_of :name
  validates_uniqueness_of :name
end
