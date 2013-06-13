class CreateAccountingBankReconciliations < ActiveRecord::Migration
  def self.up
    create_table :accounting_bank_reconciliations do |t|
      t.float :bank_balance
      t.integer :bank_balance_id
      t.integer :reconciliation_detail_id

      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_bank_reconciliations
  end
end