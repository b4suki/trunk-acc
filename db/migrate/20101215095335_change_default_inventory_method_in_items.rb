class ChangeDefaultInventoryMethodInItems < ActiveRecord::Migration
  def self.up
    change_column_default(:items, :inventory_method, "FIFO")
  end

  def self.down
    change_column_default(:items, :inventory_method, nil)
  end
end
