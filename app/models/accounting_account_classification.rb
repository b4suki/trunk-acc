class AccountingAccountClassification < ActiveRecord::Base
  has_many :accounting_accounts, :foreign_key => "account_classification_id"
end
