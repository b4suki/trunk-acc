class CreateTransItemStatuses < ActiveRecord::Migration
  def self.up
    create_table :trans_item_statuses do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :trans_item_statuses
  end
end
