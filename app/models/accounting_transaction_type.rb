# == Schema Information
# Schema version: 20081030064618
#
# Table name: accounting_transaction_types
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  description :text
#  order       :integer(4)
#  group       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class AccountingTransactionType < ActiveRecord::Base
 
  has_many :accounting_cash_balance
end
