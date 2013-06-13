class AddColumnPurchaseBalancePayments < ActiveRecord::Migration
  def self.up
    add_column(:accounting_purchase_balances, :maturity_date, :datetime)
    add_column(:accounting_purchase_balances, :status, :string)
    add_column(:accounting_purchase_balances, :terms_of_payment, :string)
    add_column(:accounting_sale_balances, :maturity_date, :datetime)
    add_column(:accounting_sale_balances, :status, :string)
    add_column(:accounting_sale_balances, :terms_of_payment, :string)    
  end

  def self.down
      remove_column(:accounting_purchase_balances, :maturity_date)
      remove_column(:accounting_purchase_balances, :status)
      remove_column(:accounting_purchase_balances, :terms_of_payment)
      remove_column(:accounting_sale_balances, :maturity_date)
      remove_column(:accounting_sale_balances, :status)
      remove_column(:accounting_sale_balances, :terms_of_payment)
  end
end
