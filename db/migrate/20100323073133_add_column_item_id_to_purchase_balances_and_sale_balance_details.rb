class AddColumnItemIdToPurchaseBalancesAndSaleBalanceDetails < ActiveRecord::Migration
  def self.up
    add_column :accounting_purchase_balances, :item_id, :integer
    add_column :accounting_sale_balance_details, :item_id, :integer
  end

  def self.down
    remove_column(:accounting_purchase_balances, :item_id)
    remove_column(:accounting_sale_balance_details, :item_id)
  end
end
