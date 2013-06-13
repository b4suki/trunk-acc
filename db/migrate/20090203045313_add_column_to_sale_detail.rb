class AddColumnToSaleDetail < ActiveRecord::Migration
  def self.up
    add_column :accounting_sale_balance_details, :subtotal, :float
  end

  def self.down
    remove_column(:accounting_sale_balance_details, :subtotal)
  end
end
