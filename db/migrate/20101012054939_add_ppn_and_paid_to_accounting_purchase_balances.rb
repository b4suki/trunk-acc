class AddPpnAndPaidToAccountingPurchaseBalances < ActiveRecord::Migration
  def self.up
    add_column :accounting_purchase_balances, :ppn_value, :float, :limit => 50
    add_column :accounting_purchase_balances, :paid, :float, :limit => 50
  end

  def self.down
    remove_column :accounting_purchase_balances, :paid
    remove_column :accounting_purchase_balances, :ppn_value
  end
end
