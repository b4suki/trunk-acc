class AddColumnToFixedAssetDet < ActiveRecord::Migration
  def self.up
    add_column :accounting_fixed_assets, :account_id, :integer
    add_column :accounting_fixed_asset_details , :account_id, :integer
  end

  def self.down
    remove_column(:accounting_fixed_assets, :account_id)
    remove_column(:accounting_fixed_asset_details, :account_id)
  end
end
