class CreateAccountingPurchaseBalances < ActiveRecord::Migration
  def self.up
    create_table :accounting_purchase_balances do |t|
      t.string :invoice_number
      t.datetime :invoice_date
      t.integer :vendor_id
      t.string :commodity_type
      t.integer :job_id
      t.float :subtotal
      t.float :discount
      t.float :total_purchase
      t.integer :purchase_debit_kredit_id
      t.float :total_subtotal
      t.float :final_total_purchase
      t.float :total_discount
      t.integer :account_id

      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_purchase_balances
  end
end
