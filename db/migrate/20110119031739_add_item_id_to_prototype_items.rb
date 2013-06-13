class AddItemIdToPrototypeItems < ActiveRecord::Migration
  def self.up
    add_column :prototype_items, :item_id , :integer
    remove_column :prototype_items, :type_id
    remove_column :prototype_items, :name
  end

  def self.down
    remove_column :prototype_items,  :item_id
    add_column :prototype_items, :type_id , :integer
    add_column :prototype_items, :name , :string
  end
end
