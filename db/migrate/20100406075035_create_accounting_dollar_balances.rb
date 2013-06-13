class CreateAccountingDollarBalances < ActiveRecord::Migration
  def self.up
    create_table :accounting_dollar_balances do |t|
      t.date "transaction_date"
      t.string "transaction_evidence"
      t.float "dollar_balance"
      t.float "kurs"
      t.float "total_revenue"
      t.float "total_payment"
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_dollar_balances
  end
end
