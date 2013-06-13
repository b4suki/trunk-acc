class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :type_id
      t.string :item_code
      t.string :name
      t.string :alias
      t.float :stock
      t.text :description
      t.boolean :active
      t.float :price, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
