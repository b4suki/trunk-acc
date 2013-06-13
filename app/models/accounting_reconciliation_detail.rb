# == Schema Information
# Schema version: 20081030064618
#
# Table name: accounting_reconciliation_details
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  value      :float
#  debit      :boolean(1)
#  credit     :boolean(1)
#  company    :boolean(1)
#  bank       :boolean(1)
#  created_at :datetime
#  updated_at :datetime
#

class AccountingReconciliationDetail < ActiveRecord::Base
  
  attr_accessor :transaction_type 
  attr_accessor :transaction_source
  before_save :collect_boolean_value
  
    
  def collect_boolean_value
    
    if transaction_type == "debit"
      self.debit = true
      self.credit = false
    elsif transaction_type == "credit"
      self.debit = false
      self.credit = true
    end
    
    if transaction_source == "company"
      self.bank = false
      self.company = true
    elsif transaction_source == "bank"
      self.company = false
      self.bank = true
    end
  end
end
