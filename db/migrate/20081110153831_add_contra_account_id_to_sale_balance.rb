class AddContraAccountIdToSaleBalance < ActiveRecord::Migration
  def self.up
    add_column :accounting_sale_balances, :contra_account_id, :integer
  end

  def self.down
    remove_column :accounting_sale_balances, :contra_account_id
  end
end
