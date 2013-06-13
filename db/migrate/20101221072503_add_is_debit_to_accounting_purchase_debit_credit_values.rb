class AddIsDebitToAccountingPurchaseDebitCreditValues < ActiveRecord::Migration
  def self.up
    add_column :accounting_purchase_debit_credit_values, :is_debit, :boolean
  end

  def self.down
    remove_column :accounting_purchase_debit_credit_values, :is_debit
  end
end
