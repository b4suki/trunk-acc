class Currency < ActiveRecord::Base
  has_many :accounting_purchase_balances
  has_many :sale_purchase_balances
end
