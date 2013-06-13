class CreatePulsaSettings < ActiveRecord::Migration
  def self.up
    create_table :pulsa_settings do |t|
      t.integer :item_id
      t.timestamps
    end
  end

  def self.down
    drop_table :pulsa_settings
  end
end
