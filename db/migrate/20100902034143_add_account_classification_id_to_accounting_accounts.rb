class AddAccountClassificationIdToAccountingAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounting_accounts, "account_classification_id", :integer
  end

  def self.down
    remove_column :accounting_accounts, "account_classification_id"
  end
end
