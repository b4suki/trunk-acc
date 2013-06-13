class AddPaymentValueToAccountingPurchaseBalances < ActiveRecord::Migration
  def self.up
    add_column :accounting_purchase_balances, :payment_value, :float, :limit => 50
  end

  def self.down
    remove_column :accounting_purchase_balances, :payment_value
  end
end
