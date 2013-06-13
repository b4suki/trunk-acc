class RenameShipDateAndShipPayment < ActiveRecord::Migration
  def self.up
    rename_column(:accounting_sale_balances, :ship_date, :shipping_date)
    rename_column(:accounting_sale_balances, :ship_payment, :shipping_cost)
    rename_column(:accounting_purchase_balances, :ship_date, :shipping_date)
    rename_column(:accounting_purchase_balances, :ship_payment, :shipping_cost)
  end

  def self.down
    rename_column(:accounting_sale_balances, :shipping_date, :ship_date)
    rename_column(:accounting_sale_balances, :shipping_cost, :ship_payment)
    rename_column(:accounting_purchase_balances, :shipping_date, :ship_date)
    rename_column(:accounting_purchase_balances, :shipping_cost, :ship_payment)
  end
end
