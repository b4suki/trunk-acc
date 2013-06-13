class AccountingAdjustmentBalance < ActiveRecord::Base
  belongs_to :accounting_account, :foreign_key => 'account_id'
  belongs_to :contra_account, :class_name => 'AccountingAccount', :foreign_key => 'contra_account_id'

  validates_presence_of :description, :values
  validates_numericality_of :values , :greater_than => 0   
end
