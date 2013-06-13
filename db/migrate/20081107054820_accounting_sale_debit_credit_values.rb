class AccountingSaleDebitCreditValues < ActiveRecord::Migration
  def self.up
    create_table :accounting_sale_debit_credit_values do |t|
      t.integer :sale_balance_id
      t.integer :sale_debit_credit_id
      t.float :value
      t.float :total_value
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_sale_debit_credit_values
  end
end

