# == Schema Information
# Schema version: 20081030064618
#
# Table name: accounting_bank_reconciliations
#
#  id                       :integer(4)      not null, primary key
#  company_cash_balance     :float
#  bank_balance_id          :integer(4)
#  reconciliation_detail_id :integer(4)
#  created_at               :datetime
#  updated_at               :datetime
#

class AccountingBankReconciliations < ActiveRecord::Base
   attr_accessor :value
end
