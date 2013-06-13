class AccountingManualJournal < AccountingJournal
  has_many :accounting_mutations, :foreign_key => "journal_id"
  has_many :tax_credits, :class_name => TaxCredit, :foreign_key => "manual_journal_id"
  belongs_to:accounting_sale_balances, :foreign_key => "sale_id"
end