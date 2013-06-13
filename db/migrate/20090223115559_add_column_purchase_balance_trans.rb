class AddColumnPurchaseBalanceTrans < ActiveRecord::Migration
  def self.up 
    add_column :accounting_purchase_balances, :group_id, :integer
  end

  def self.down
    remove_column(:accounting_purchase_balances, :group_id)
  end
end
