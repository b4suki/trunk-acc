class AddDiscPercentageIdToAccountingPurchaseBalanceDetails < ActiveRecord::Migration
  def self.up
    add_column :accounting_purchase_balance_details, :disc_percentage, :float
  end

  def self.down
    remove_column :accounting_purchase_balance_details, :disc_percentage
  end
end
