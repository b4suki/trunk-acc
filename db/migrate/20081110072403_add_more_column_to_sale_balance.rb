class AddMoreColumnToSaleBalance < ActiveRecord::Migration
  def self.up
    add_column :accounting_sale_balances, :price, :float
    add_column :accounting_sale_balances, :qty, :float    
  end

  def self.down
    remove_column :accounting_sale_balances, :price
    remove_column :accounting_sale_balances, :qty   
  end
end
