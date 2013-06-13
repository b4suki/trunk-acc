class AddTaxableToAccountingSaleBalances < ActiveRecord::Migration
  def self.up
    add_column :accounting_sale_balances, :taxable, :boolean
  end

  def self.down
    remove_column :accounting_sale_balances, :taxable
  end
end
