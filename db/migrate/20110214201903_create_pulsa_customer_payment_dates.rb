class CreatePulsaCustomerPaymentDates < ActiveRecord::Migration
  def self.up
    create_table :pulsa_customer_payment_dates do |t|
      t.date :payment_date
      t.boolean :payment_status
      t.integer :pulsa_customer_id
      t.timestamps
    end
  end

  def self.down
    drop_table :pulsa_customer_payment_dates
  end
end
