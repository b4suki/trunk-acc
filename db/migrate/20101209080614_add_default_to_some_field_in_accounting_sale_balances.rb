class AddDefaultToSomeFieldInAccountingSaleBalances < ActiveRecord::Migration
  def self.up
    change_column_default(:accounting_sale_balances, :discount, 0)
    change_column_default(:accounting_sale_balances, :amount_account_payable, 0)
    change_column_default(:accounting_sale_balances, :total_discount, 0)
    change_column_default(:accounting_sale_balances, :disc_percentage, 0)
    change_column_default(:accounting_sale_balances, :kurs, 0)
    change_column_default(:accounting_sale_balances, :ppn_value, 0)
    change_column_default(:accounting_sale_balances, :payment_value, 0)
    change_column_default(:accounting_sale_balances, :paid, 0)
  end

  def self.down
    change_column_default(:accounting_sale_balances, :discount, nil)
    change_column_default(:accounting_sale_balances, :amount_account_payable, nil)
    change_column_default(:accounting_sale_balances, :total_discount, nil)
    change_column_default(:accounting_sale_balances, :disc_percentage, nil)
    change_column_default(:accounting_sale_balances, :kurs, nil)
    change_column_default(:accounting_sale_balances, :ppn_value, nil)
    change_column_default(:accounting_sale_balances, :payment_value, nil)
    change_column_default(:accounting_sale_balances, :paid, nil)
  end
end
