class AccountingCashFlowCategory < ActiveRecord::Base
  has_many :debit_credits, :class_name => "AccountingCashFlowDebitCredit", :foreign_key => :category_id
  has_many :accounts, :through => :debit_credits, :foreign_key => :account_id

  belongs_to :accounting_cash_flow_activity, :foreign_key => :activity_id
  validates_presence_of :title
end
