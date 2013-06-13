class AddColumnReceivedToAccountingPurchaseBalances < ActiveRecord::Migration
  def self.up
    add_column :accounting_purchase_balances, "received", :boolean
  end

  def self.down
    remove_column(:accounting_purchase_balances, "received")
  end
end
