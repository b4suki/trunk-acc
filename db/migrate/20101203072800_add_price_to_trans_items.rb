class AddPriceToTransItems < ActiveRecord::Migration
  def self.up
    add_column :trans_items, :price, :float, :limit => 50, :default => 0
  end

  def self.down
    remove_column :trans_items, :price
  end
end
