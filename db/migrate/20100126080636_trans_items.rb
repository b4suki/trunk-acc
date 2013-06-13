class TransItems < ActiveRecord::Migration
  def self.up
    create_table :trans_items do |t|
      t.integer :user_id
      t.integer :item_id
      t.float :qty
      t.integer  :status
      t.text :description
      t.integer :generated_by
      t.datetime :generated_time
      t.timestamps
    end
  end

  def self.down
    drop_table :trans_items
  end
end
