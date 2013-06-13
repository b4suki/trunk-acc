class AddDescriptionColumnToAccountingDollarBalances < ActiveRecord::Migration
  def self.up
    add_column :accounting_dollar_balances, "description", :text
  end

  def self.down
    remove_column(:accounting_dollar_balances, "description")
  end
end
