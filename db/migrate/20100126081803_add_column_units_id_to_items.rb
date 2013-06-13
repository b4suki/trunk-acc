class AddColumnUnitsIdToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :unit_id, :integer
  end

  def self.down
    remove_column(:items, :unit_id)
  end
end
