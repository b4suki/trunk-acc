class AddItemIdToDetailPulsaCutomers < ActiveRecord::Migration
  def self.up
    add_column :detail_pulsa_customers, :item_id, :integer
  end

  def self.down
    remove_column :detail_pulsa_customers, :item_id
  end
end
