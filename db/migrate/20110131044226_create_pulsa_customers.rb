class CreatePulsaCustomers < ActiveRecord::Migration
  def self.up
    create_table :pulsa_customers do |t|
      t.date :date_install
      t.integer :customer_id
      t.integer :item_id
      t.string :simcard
      t.string :sn
      t.string :nopol
      t.integer :car_id
      t.float :saldo
      t.date :aktif

      t.timestamps
    end
  end

  def self.down
    drop_table :pulsa_customers
  end
end
