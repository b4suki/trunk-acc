class AddPriceAndDateBuyToTransItems < ActiveRecord::Migration
  def self.up
    add_column :trans_items, :sequence, :integer
    add_column :trans_items, :date_buy, :date
  end

  def self.down
    remove_column :trans_items, :date_buy
    remove_column :trans_items, :sequence
  end
end
