class AccountingSaleBalanceServiceDetail < ActiveRecord::Base
  belongs_to :sale_balance, :class_name => "AccountingSaleBalance", :foreign_key => "sale_balance_id"
  belongs_to :service
end
