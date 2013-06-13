class AddColumnShipDateOnAccountingPurchaseBalance < ActiveRecord::Migration
  def self.up
    add_column :accounting_purchase_balances, :ship_date, :datetime
    add_column :accounting_purchase_balances, :ship_payment, :float, :default => 0
  end 
  
  def self.down
    remove_column(:accounting_purchase_balances, :ship_date)
    remove_column(:accounting_purchase_balances, :ship_payment)
  end
end
