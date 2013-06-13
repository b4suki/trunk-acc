class AddColumnSentToAccountingSaleBalances < ActiveRecord::Migration
  def self.up
    add_column :accounting_sale_balances, "sent", :boolean
  end

  def self.down
    remove_column(:accounting_sale_balances, "sent")
  end
end
