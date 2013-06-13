class AddReceivedToAccountingPurchaseBalanceDetails < ActiveRecord::Migration
  def self.up
    add_column :accounting_purchase_balance_details, :received, :boolean
  end

  def self.down
    remove_column :accounting_purchase_balance_details, :received
  end
end
