class CreateVendors < ActiveRecord::Migration
  def self.up
    create_table :vendors do |t|
      t.string :name
      t.text :description
      t.text :address
      t.string :phone
      t.string :fax
      t.string :contact

      t.timestamps
    end
  end

  def self.down
    drop_table :vendors
  end
end
