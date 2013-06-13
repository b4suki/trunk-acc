class AddTypeAndCompletedToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :type, :string
    add_column :items, :completed, :boolean
  end

  def self.down
    remove_column :items, :type
    remove_column :items, :completed
  end
end
