class AccountingJournalValue < ActiveRecord::Base
  belongs_to :journal, :foreign_key => "journal_id", :class_name => 'AccountingJournal'
  belongs_to :account, :foreign_key => "account_id", :class_name => 'AccountingAccount'
end
