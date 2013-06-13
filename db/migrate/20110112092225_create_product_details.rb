class CreateProductDetails < ActiveRecord::Migration
  def self.up
    create_table :product_details do |t|
      t.integer :item_id
      t.integer :product_id
      t.integer :quntity

      t.timestamps
    end
  end

  def self.down
    drop_table :product_details
  end
end
