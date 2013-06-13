class CreateAccountingSaleBalances < ActiveRecord::Migration
  def self.up
    create_table :accounting_sale_balances do |t|
      t.string :invoice_number
      t.datetime :invoice_date
      t.integer :vendor_id
      t.string :commodity_type
      t.integer :job_id
      t.text :job_description   
      t.float :subtotal , :default => 0
      t.float :discount      
      t.integer :sale_debit_credit_id
      t.float :total_subtotal , :default => 0
      t.float :final_total_sale 
      t.float :total_discount 
      t.integer :account_id
      t.integer :customer_id
      t.float :total_sale , :default => 0
      
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_sale_balances
  end
end
