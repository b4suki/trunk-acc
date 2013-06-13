class AccountingPurchaseBalanceDetail < ActiveRecord::Base
  belongs_to :accounting_purchase_balance, :foreign_key => 'purchase_balance_id'
  belongs_to :item
end
