class AddColumnPercentageToSaleBalance < ActiveRecord::Migration
  def self.up
     add_column :accounting_sale_balances, :disc_percentage, :float
  end

  def self.down
    remove_column :accounting_sale_balances, :disc_percentage
  end
end
