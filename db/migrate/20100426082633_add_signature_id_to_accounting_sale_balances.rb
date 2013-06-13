class AddSignatureIdToAccountingSaleBalances < ActiveRecord::Migration
  def self.up
    add_column :accounting_sale_balances, "signature_id", :integer
  end

  def self.down
    remove_column(:accounting_sale_balances, "signature_id")
  end
end
