class AddDefaultToSomeFieldInAccountingPurchaseBalances < ActiveRecord::Migration
  def self.up
    change_column_default(:accounting_purchase_balances, :subtotal, 0)
    change_column_default(:accounting_purchase_balances, :discount, 0)
    change_column_default(:accounting_purchase_balances, :transaction_value, 0)
    change_column_default(:accounting_purchase_balances, :total_subtotal, 0)
    change_column_default(:accounting_purchase_balances, :amount_account_receivable, 0)
    change_column_default(:accounting_purchase_balances, :total_discount, 0)
    change_column_default(:accounting_purchase_balances, :disc_percentage, 0)
    change_column_default(:accounting_purchase_balances, :kurs, 0)
    change_column_default(:accounting_purchase_balances, :paid, 0)
    change_column_default(:accounting_purchase_balances, :payment_value, 0)
  end

  def self.down
    change_column_default(:accounting_purchase_balances, :subtotal, nil)
    change_column_default(:accounting_purchase_balances, :discount, nil)
    change_column_default(:accounting_purchase_balances, :transaction_value, nil)
    change_column_default(:accounting_purchase_balances, :total_subtotal, nil)
    change_column_default(:accounting_purchase_balances, :amount_account_receivable, nil)
    change_column_default(:accounting_purchase_balances, :total_discount, nil)
    change_column_default(:accounting_purchase_balances, :disc_percentage, nil)
    change_column_default(:accounting_purchase_balances, :kurs, nil)
    change_column_default(:accounting_purchase_balances, :paid, nil)
    change_column_default(:accounting_purchase_balances, :payment_value, nil)
  end
end
