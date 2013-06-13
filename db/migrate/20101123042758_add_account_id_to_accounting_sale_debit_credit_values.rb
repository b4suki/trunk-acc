class AddAccountIdToAccountingSaleDebitCreditValues < ActiveRecord::Migration
  def self.up
    add_column :accounting_sale_debit_credit_values, :account_id, :integer
  end

  def self.down
    remove_column :accounting_sale_debit_credit_values, :account_id
  end
end
