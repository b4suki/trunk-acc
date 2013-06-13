class CreatePrototypeItemDetails < ActiveRecord::Migration
  def self.up
    create_table :prototype_item_details do |t|
      t.integer :prototype_item_id
      t.integer :item_id
      t.integer :quantity

      t.timestamps
    end
  end

  def self.down
    drop_table :prototype_item_details
  end
end
