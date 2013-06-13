# == Schema Information
# Schema version: 20081030064618
#
# Table name: accounting_sale_debit_credits
#
#  id          :integer(4)      not null, primary key
#  account_id  :integer(4)
#  description :text
#  debit       :boolean(1)
#  credit      :boolean(1)
#  value       :float
#  total_value :float
#  created_at  :datetime
#  updated_at  :datetime
#

class AccountingSaleDebitCredit < ActiveRecord::Base
  has_many :accounting_sale_balances
  belongs_to :accounting_account , :foreign_key => "account_id"
  has_many :values, :class_name => "AccountingSaleDebitCreditValue", :foreign_key => "sale_debit_credit_id"
  validates_presence_of :account_id
end
