class AddColumnSaleDetails < ActiveRecord::Migration
  def self.up
    add_column :accounting_sale_balance_details, :sale_balance_id, :integer
  end

  def self.down
    remove_column(:accounting_sale_balance_details,:sale_balance_id)
  end
end
