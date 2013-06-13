class AccountTypeToAccountingAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounting_accounts , :account_type, :string
  end

  def self.down
    remove_column :accounting_accounts, :account_type
  end
end
