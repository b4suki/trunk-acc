class AccountingJournal < ActiveRecord::Base
  has_many :values, :foreign_key => "journal_id", :class_name => 'AccountingJournalValue', :dependent => :destroy
end
