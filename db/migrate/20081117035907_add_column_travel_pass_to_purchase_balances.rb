class AddColumnTravelPassToPurchaseBalances < ActiveRecord::Migration
  def self.up
    add_column :accounting_purchase_balances , :travel_pass, :string
  end

  def self.down
    remove_column(:accounting_purchase_balances, :travel_pass)
  end
end
