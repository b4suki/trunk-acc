class CreateAccountingPurchaseDebitCreditValues < ActiveRecord::Migration
  def self.up
    create_table :accounting_purchase_debit_credit_values do |t|
      t.integer :purchase_balance_id
      t.integer :purchase_debit_credit_id
      t.float :value
      t.float :total_value
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_purchase_debit_credit_values
  end
end
