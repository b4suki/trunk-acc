class ChangeColumnOnPurchase < ActiveRecord::Migration
  def self.up
    rename_column :accounting_purchase_balances, :status, :status_id
    change_column :accounting_purchase_balances, :status_id, :integer
  end

  def self.down
    change_column :accounting_purchase_balances, :status_id, :string
    rename_column :accounting_purchase_balances, :status_id, :status
  end
end
