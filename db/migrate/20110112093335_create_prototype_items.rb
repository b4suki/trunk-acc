class CreatePrototypeItems < ActiveRecord::Migration
  def self.up
    create_table :prototype_items do |t|
      t.string :name
      t.integer :type_id
      t.string :description
      t.boolean :active

      t.timestamps
    end
  end

  def self.down
    drop_table :prototype_items
  end
end
