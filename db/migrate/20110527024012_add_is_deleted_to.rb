class AddIsDeletedTo < ActiveRecord::Migration
  def self.up
    add_column :item_details, :is_deleted, :boolean
  end

  def self.down
    remove_column :item_details, :is_deleted
  end
end
