class CreateItemHistories < ActiveRecord::Migration
  def self.up
    create_table :item_histories do |t|
      t.integer :item_id
      t.date :last_date
      t.integer :last_stock

      t.timestamps
    end
  end

  def self.down
    drop_table :item_histories
  end
end
