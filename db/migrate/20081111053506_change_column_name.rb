class ChangeColumnName < ActiveRecord::Migration
  def self.up
    rename_column(:accounting_bank_balances, :evidence_id, :evidence)
    rename_column(:accounting_bank_balances, :value, :transaction_value )
    rename_column(:accounting_sale_balances, :commodity_type, :description)
    rename_column(:accounting_sale_balances, :total_sale, :transaction_value)
    rename_column(:accounting_purchase_balances, :commodity_type, :description)
    rename_column(:accounting_purchase_balances, :total_purchase, :transaction_value)
  end

  def self.down
    rename_column(:accounting_bank_balances, :evidence, :evidence_id)
    rename_column(:accounting_bank_balances, :transaction_value, :value )
    rename_column(:accounting_sale_balances, :description, :commodity_type)
    rename_column(:accounting_sale_balances, :transaction_value, :total_sale)
    rename_column(:accounting_purchase_balances, :description, :commodity_type)
    rename_column(:accounting_purchase_balances, :transaction_value, :total_purchase)
  end
end
