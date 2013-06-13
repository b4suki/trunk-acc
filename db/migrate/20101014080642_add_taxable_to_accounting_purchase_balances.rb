class AddTaxableToAccountingPurchaseBalances < ActiveRecord::Migration
  def self.up
    add_column :accounting_purchase_balances, :taxable, :boolean
  end

  def self.down
    remove_column :accounting_purchase_balances, :taxable
  end
end
