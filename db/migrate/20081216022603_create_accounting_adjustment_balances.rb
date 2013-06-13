class CreateAccountingAdjustmentBalances < ActiveRecord::Migration
  def self.up
    create_table :accounting_adjustment_balances do |t|
      t.date :adjusment_date
      t.string :description, :job_no ,:evidence_no
      t.integer :account_id, :contra_account_id
      t.column :values, :double
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_adjustment_balances
  end
end
