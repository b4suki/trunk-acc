class WorksheetToAccountingAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounting_accounts , :worksheet, :string
  end

  def self.down
    remove_column :accounting_accounts , :worksheet
  end
end
