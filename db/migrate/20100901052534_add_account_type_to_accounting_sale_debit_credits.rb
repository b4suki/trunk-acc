class AddAccountTypeToAccountingSaleDebitCredits < ActiveRecord::Migration
  def self.up
    add_column :accounting_sale_debit_credits, "account_type", :string
  end

  def self.down
    remove_column :accounting_sale_debit_credits, "account_type"
  end
end
