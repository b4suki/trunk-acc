class AddColumnIsAdditionToTransItems < ActiveRecord::Migration
  def self.up
    add_column :trans_items, "is_addition", :boolean, :default => false
  end

  def self.down
    remove_column(:trans_items, "is_addition")
  end
end
