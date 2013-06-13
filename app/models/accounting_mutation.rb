class AccountingMutation < ActiveRecord::Base
  belongs_to :accounting_purchase_balance, :foreign_key => 'transaction_id'
  belongs_to :accounting_sale_balance
  belongs_to :vendor, :foreign_key => 'vendor_customer_id'
  belongs_to :customer, :foreign_key => 'vendor_customer_id'
  belongs_to :manual_journal, :class_name => "AccountingManualJournal", :foreign_key => "journal_id", :dependent => :destroy
end
