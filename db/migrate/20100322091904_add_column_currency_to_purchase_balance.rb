class AddColumnCurrencyToPurchaseBalance < ActiveRecord::Migration
  def self.up
    add_column :accounting_purchase_balances, :currency_id, :integer
  end

  def self.down
    remove_column(:accounting_purchase_balances, :currency_id)
  end
end
