class RenameColumnAdjustmentBalances < ActiveRecord::Migration
  def self.up
    rename_column(:accounting_adjustment_balances, :adjusment_date, :adjustment_date)
  end

  def self.down
    rename_column(:accounting_adjustment_balances, :adjustment_date, :adjusment_date)
  end
end
