class AddTotalToItemDetails < ActiveRecord::Migration
  def self.up
    add_column :item_details, :total, :float, :limit => 50, :default => 0
  end

  def self.down
    remove_column :item_details, :total
  end
end
