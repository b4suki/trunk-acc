class AddNewColumnToSaleBalances < ActiveRecord::Migration
  def self.up
    add_column :accounting_sale_balances, :po_num, :string
    add_column :accounting_sale_balances, :travel_pass, :string
  end

  def self.down
    remove_column :accounting_sale_balances, :po_num
    remove_column :accounting_sale_balances, :travel_pass
  end
end
