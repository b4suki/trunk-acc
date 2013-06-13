class CreateTrialBalances < ActiveRecord::Migration
  def self.up
    create_table :trial_balances do |t|
      t.integer :account_id
      t.float :last_saldo
      t.datetime :transaction_date

      t.timestamps
    end
  end

  def self.down
    drop_table :trial_balances
  end
end
