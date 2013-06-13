class AddEvidenceToSaleAndPurchaseBalances < ActiveRecord::Migration
  def self.up
    add_column :accounting_sale_balances, :evidence, :string
    add_column :accounting_purchase_balances, :evidence, :string
  end

  def self.down
    remove_column :accounting_sale_balances, :evidence
    remove_column :accounting_purchase_balances, :evidence
  end
end
