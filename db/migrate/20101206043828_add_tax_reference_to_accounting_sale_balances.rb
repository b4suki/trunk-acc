class AddTaxReferenceToAccountingSaleBalances < ActiveRecord::Migration
  def self.up
    add_column :accounting_sale_balances, :tax_reference, :string
  end

  def self.down
    remove_column :accounting_sale_balances, :tax_reference
  end
end
