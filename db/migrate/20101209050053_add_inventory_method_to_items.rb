class AddInventoryMethodToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :inventory_method, :string
  end

  def self.down
    remove_column :items, :inventory_method
  end
end
