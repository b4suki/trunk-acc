class CreateAccountingCashFlowDebitCredits < ActiveRecord::Migration
  def self.up
    create_table :accounting_cash_flow_debit_credits do |t|
      t.integer :category_id
      t.integer :account_id

      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_cash_flow_debit_credits
  end
end
