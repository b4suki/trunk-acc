class TaxCredit < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 20

  belongs_to :vendor
  belongs_to :customer
  belongs_to :manual_journal, :class_name => AccountingManualJournal, :foreign_key => :manual_journal_id

  def self.one_month_tax_credit_amount(month, year)
    total = 0
    TaxCredit.find(:all, :conditions => "MONTH(ssp_date)=#{month} AND YEAR(ssp_date)=#{year}").each { |tax_credit| total += tax_credit.amount }
    total
  end
end
