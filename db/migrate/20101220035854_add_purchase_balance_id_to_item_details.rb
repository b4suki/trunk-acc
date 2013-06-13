class AddPurchaseBalanceIdToItemDetails < ActiveRecord::Migration
  def self.up
    add_column :item_details, :purchase_balance_id, :integer
  end

  def self.down
    remove_column :item_details, :purchase_balance_id
  end
end
