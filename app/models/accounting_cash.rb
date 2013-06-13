class AccountingCash < ActiveRecord::Base
  belongs_to :accounting_account, :foreign_key => "account_id"
end
