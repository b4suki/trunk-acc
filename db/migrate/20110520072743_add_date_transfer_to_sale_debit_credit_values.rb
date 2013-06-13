class AddDateTransferToSaleDebitCreditValues < ActiveRecord::Migration
  def self.up
    add_column :accounting_sale_debit_credit_values, :transfer_date, :date
  end

  def self.down
    remove_column :accounting_sale_debit_credit_values, :transfer_date
  end
end
