class AddProductIdToTransItems < ActiveRecord::Migration
  def self.up
    add_column :trans_items, :product_id, :integer
  end

  def self.down
    remove_column :trans_items, :product_id
  end
end
