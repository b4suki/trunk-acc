class AccountingSaleBalanceDetail < ActiveRecord::Base
  belongs_to :accounting_sale_balance , :foreign_key => 'sale_balance_id'
  belongs_to :item
end
