class AccountingFixedAssetDetail < ActiveRecord::Base
  belongs_to :accounting_fixed_asset  , :foreign_key => "fixed_asset_id"
  belongs_to :accounting_account, :foreign_key => 'account_id'
end
