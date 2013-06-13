class AddValueToItemHistories < ActiveRecord::Migration
  def self.up
    add_column :item_histories, :value, :float
  end

  def self.down
    remove_column :item_histories, :value
  end
end
