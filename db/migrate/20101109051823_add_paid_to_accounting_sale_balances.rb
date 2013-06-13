class AddPaidToAccountingSaleBalances < ActiveRecord::Migration
  def self.up
    add_column :accounting_sale_balances, :paid, :float, :limit => 50
  end

  def self.down
    remove_column :accounting_sale_balances, :paid
  end
end
