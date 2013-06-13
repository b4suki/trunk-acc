class AddTotalValueToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :total_value, :float, :limit => 50, :default => 0
  end

  def self.down
    remove_column :items, :total_value
  end
end
