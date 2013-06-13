class AddColumnPpnValueToAccountingSaleBalances < ActiveRecord::Migration
  def self.up
    add_column :accounting_sale_balances, :ppn_value, :float
  end

  def self.down
    remove_column(:accounting_sale_balances, :ppn_value)
  end
end
