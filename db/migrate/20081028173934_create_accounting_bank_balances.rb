class CreateAccountingBankBalances < ActiveRecord::Migration
  def self.up
    create_table :accounting_bank_balances do |t|
      t.text :description
      t.string :evidence_id
      t.integer :contra_account_id
      t.string :cg_gb_no
      t.boolean :debit
      t.boolean :credit
      t.float :cash_balance, :default => 0
      t.float :value, :default => 0
      t.float :total_debit, :default => 0
      t.float :total_credit, :default => 0
      t.integer :job_id
      t.integer :account_id
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_bank_balances
  end
end
