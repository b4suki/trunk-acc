class AdjustmentAccount < ActiveRecord::Base 
  has_many :accounting_fixed_assets
  has_many :fixed_asset_details
  #has_many :fixed_asset_details,:class_name => "AccountingFixedAssetDetail", :foreign_key => 'account_id'
  belongs_to :accounting_account, :foreign_key => 'account_id'    
end