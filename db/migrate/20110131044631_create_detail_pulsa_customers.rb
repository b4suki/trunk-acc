class CreateDetailPulsaCustomers < ActiveRecord::Migration
  def self.up
    create_table :detail_pulsa_customers do |t|
      t.integer :pulsa_customer_id
      t.date :date_pulsa
      t.float :pulsa

      t.timestamps
    end
  end

  def self.down
    drop_table :detail_pulsa_customers
  end
end
