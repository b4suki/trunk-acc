class AddColumnToAdjustmentAccounts < ActiveRecord::Migration
  def self.up
    add_column :adjustment_accounts, :debit_credit, :boolean
  end

  def self.down
    remove_column(:adjustment_accounts, :debit_credit)
  end
end
