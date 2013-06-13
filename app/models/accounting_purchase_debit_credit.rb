# == Schema Information
# Schema version: 20081030064618
#
# Table name: accounting_purchase_debit_credits
#
#  id          :integer(4)      not null, primary key
#  account_id  :integer(4)
#  description :text
#  debit       :boolean(1)
#  credit      :boolean(1)
#  created_at  :datetime
#  updated_at  :datetime
#

class AccountingPurchaseDebitCredit < ActiveRecord::Base
  belongs_to :accounting_account , :foreign_key => "account_id"
  has_many :accounting_purchase_balances
  has_many :values, :class_name => "AccountingPurchaseDebitCreditValue", :foreign_key => :purchase_debit_credit_id
  validates_presence_of :account_id
end
