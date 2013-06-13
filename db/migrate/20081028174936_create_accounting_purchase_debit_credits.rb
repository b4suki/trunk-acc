class CreateAccountingPurchaseDebitCredits < ActiveRecord::Migration
  def self.up
    create_table :accounting_purchase_debit_credits do |t|
      t.integer :account_id
      t.text :description
      t.boolean :debit
      t.boolean :credit
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_purchase_debit_credits
  end
end
