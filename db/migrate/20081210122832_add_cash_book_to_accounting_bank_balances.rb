class AddCashBookToAccountingBankBalances < ActiveRecord::Migration
  def self.up
    add_column :accounting_bank_balances, :bkk, :string
    add_column :accounting_bank_balances, :bkm, :string
  end

  def self.down
    remove_column :accounting_bank_balances, :bkk
    remove_column :accounting_bank_balances, :bkm
  end
end
