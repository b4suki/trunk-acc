class AddActionNameToAction < ActiveRecord::Migration
  def self.up
    add_column :actions, :action_name, :string
  end

  def self.down
    remove_column :actions, :action_name
  end
end
