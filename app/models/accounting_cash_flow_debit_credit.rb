class AccountingCashFlowDebitCredit < ActiveRecord::Base
  belongs_to :category, :class_name => "AccountingCashFlowCategory", :foreign_key => :category_id
  belongs_to :account, :class_name => "AccountingAccount", :foreign_key => :account_id
end
