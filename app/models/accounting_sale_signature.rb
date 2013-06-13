class AccountingSaleSignature < ActiveRecord::Base
  has_many :accounting_sale_balances, :foreign_key => :signature_id
end
