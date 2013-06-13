class RenameColumnAccountingFixedAssets < ActiveRecord::Migration
  def self.up
    rename_column(:accounting_fixed_assets, :account_id, :adjustment_account_id)
  end

  def self.down
    rename_column(:accounting_fixed_assets, :adjustment_account_id, :account_id)
  end
end
