class ChangeColumnVendorinSaleBalances < ActiveRecord::Migration
  def self.up
    remove_column(:accounting_sale_balances, :vendor_id)
  end

  def self.down
    add_column(:accounting_sale_balances, :vendor_id)
  end
end
