class RenameColumnTotalToAccountPayableReceivable < ActiveRecord::Migration
  def self.up
    rename_column(:accounting_purchase_balances, :final_total_purchase, :amount_account_receivable)
    rename_column(:accounting_sale_balances, :final_total_sale, :amount_account_payable)
  end

  def self.down
    rename_column(:accounting_purchase_balances, :amount_account_receivable, :final_total_purchase)
    rename_column(:accounting_purchase_balances, :amount_account_payable, :final_total_sale)
  end
end
