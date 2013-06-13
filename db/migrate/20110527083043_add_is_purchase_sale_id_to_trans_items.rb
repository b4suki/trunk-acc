class AddIsPurchaseSaleIdToTransItems < ActiveRecord::Migration
  def self.up
    add_column :trans_items, :purchase_sale_id, :integer
    remove_column :trans_item_statuses, :purchase_sale_id
  end

  def self.down
    add_column :trans_item_statuses, :purchase_sale_id, :integer
    remove_column :trans_items, :purchase_sale_id
  end
end
