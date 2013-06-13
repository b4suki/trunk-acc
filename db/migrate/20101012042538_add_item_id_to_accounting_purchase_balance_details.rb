class AddItemIdToAccountingPurchaseBalanceDetails < ActiveRecord::Migration
  def self.up
    add_column :accounting_purchase_balance_details, :item_id, :integer
  end

  def self.down
    remove_column :accounting_purchase_balance_details, :item_id
  end
end
