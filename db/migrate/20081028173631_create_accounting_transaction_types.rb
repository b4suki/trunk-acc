class CreateAccountingTransactionTypes < ActiveRecord::Migration
  def self.up
    create_table :accounting_transaction_types do |t|
      t.string :name
      t.text :description
      t.integer :order
      t.string :group

      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_transaction_types
  end
end
