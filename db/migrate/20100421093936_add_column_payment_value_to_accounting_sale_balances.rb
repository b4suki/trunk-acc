class AddColumnPaymentValueToAccountingSaleBalances < ActiveRecord::Migration
  def self.up
    add_column :accounting_sale_balances, "payment_value", :float
  end

  def self.down
    remove_column(:accounting_sale_balances, "payment_value")
  end
end
