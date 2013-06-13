class AddIsPurchaseSaleIdToTransItemStatuses < ActiveRecord::Migration
  def self.up
    add_column :trans_item_statuses, :purchase_sale_id, :integer
  end

  def self.down
    remove_column :trans_item_statuses, :purchase_sale_id
  end
end
