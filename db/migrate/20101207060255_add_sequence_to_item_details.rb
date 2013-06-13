class AddSequenceToItemDetails < ActiveRecord::Migration
  def self.up
    add_column :item_details, :sequence, :integer
  end

  def self.down
    remove_column :item_details, :sequence
  end
end
