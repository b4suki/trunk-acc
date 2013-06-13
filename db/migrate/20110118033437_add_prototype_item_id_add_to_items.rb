class AddPrototypeItemIdAddToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :prototype_item_id, :integer
  end

  def self.down
    remove_column :items, :prototype_item_id
  end
end
