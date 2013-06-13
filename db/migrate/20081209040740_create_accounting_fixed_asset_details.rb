class CreateAccountingFixedAssetDetails < ActiveRecord::Migration
  def self.up
    create_table :accounting_fixed_asset_details do |t|
      t.date :transaction_date
      t.float :asset_values, :depreciation_values,:aje_values
      t.integer :fixed_asset_id
    end
  end

  def self.down
    drop_table(:accounting_fixed_asset_details)
  end
end
