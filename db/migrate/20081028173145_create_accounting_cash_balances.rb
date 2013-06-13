class CreateAccountingCashBalances < ActiveRecord::Migration
  def self.up
    create_table :accounting_cash_balances do |t|
      t.text :description
      t.string :bkk
      t.string :bkm
      t.integer :job_id
      t.integer :transaction_type_id
      t.float :total_revenue, :default => 0
      t.float :total_payment, :default => 0
      t.float :cash_balance, :default => 0
      t.float :transaction_value, :default => 0
      t.float :total_payment_by_type, :default => 0
      t.integer :account_id
      t.string :evidence
      t.integer :contra_account_id, :default => 0
      
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_cash_balances
  end
end
