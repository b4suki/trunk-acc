class UpdateFloatFieldToDouble < ActiveRecord::Migration
  def self.up
    # accounting_bank_balances
    change_column(:accounting_bank_balances, :cash_balance, :double)
    change_column(:accounting_bank_balances, :transaction_value, :double)
    change_column(:accounting_bank_balances, :total_debit, :double)
    change_column(:accounting_bank_balances, :total_credit, :double)

    # accounting_bank_reconciliations
    change_column(:accounting_bank_reconciliations, :bank_balance, :double)

    # accounting_cash_balances
    change_column(:accounting_cash_balances, :total_revenue, :double)
    change_column(:accounting_cash_balances, :total_payment, :double)
    change_column(:accounting_cash_balances, :cash_balance, :double)
    change_column(:accounting_cash_balances, :transaction_value, :double)
    change_column(:accounting_cash_balances, :total_payment_by_type, :double)

    # accounting_fixed_assets
    change_column(:accounting_fixed_assets, :value, :double)
    change_column(:accounting_fixed_assets, :scrap_value, :double)

    # accounting_fixed_asset_details
    change_column(:accounting_fixed_asset_details, :asset_values, :double)
    change_column(:accounting_fixed_asset_details, :depreciation_values, :double)
    change_column(:accounting_fixed_asset_details, :aje_values, :double)

    #accounting_purchase_balances
    change_column(:accounting_purchase_balances, :subtotal, :double)
    change_column(:accounting_purchase_balances, :discount, :double)
    change_column(:accounting_purchase_balances, :transaction_value, :double)
    change_column(:accounting_purchase_balances, :total_subtotal, :double)
    change_column(:accounting_purchase_balances, :final_total_purchase, :double)
    change_column(:accounting_purchase_balances, :total_discount, :double)
    change_column(:accounting_purchase_balances, :price, :double)
    change_column(:accounting_purchase_balances, :qty, :double)
    change_column(:accounting_purchase_balances, :disc_percentage, :double)

    # accounting_purchase_debit_credit_values
    change_column(:accounting_purchase_debit_credit_values, :value, :double)
    change_column(:accounting_purchase_debit_credit_values, :total_value, :double)

    # accounting_sale_balances
    change_column(:accounting_sale_balances, :subtotal, :double)
    change_column(:accounting_sale_balances, :discount, :double)
    change_column(:accounting_sale_balances, :total_subtotal, :double)
    change_column(:accounting_sale_balances, :final_total_sale, :double)
    change_column(:accounting_sale_balances, :total_discount, :double)
    change_column(:accounting_sale_balances, :transaction_value, :double)
    change_column(:accounting_sale_balances, :price, :double)
    change_column(:accounting_sale_balances, :qty, :double)
    change_column(:accounting_sale_balances, :disc_percentage, :double)

    # accounting_sale_debit_credit_values
    change_column(:accounting_sale_debit_credit_values, :value, :double)
    change_column(:accounting_sale_debit_credit_values, :total_value, :double)

    # trial_balances
    change_column(:trial_balances, :last_saldo, :double)
  end

  def self.down
    # accounting_bank_balances
    change_column(:accounting_bank_balances, :cash_balance, :float)
    change_column(:accounting_bank_balances, :transaction_value, :float)
    change_column(:accounting_bank_balances, :total_debit, :float)
    change_column(:accounting_bank_balances, :total_credit, :float)

    # accounting_bank_reconciliations
    change_column(:accounting_bank_reconciliations, :bank_balance, :float)

    # accounting_cash_balances
    change_column(:accounting_cash_balances, :total_revenue, :float)
    change_column(:accounting_cash_balances, :total_payment, :float)
    change_column(:accounting_cash_balances, :cash_balance, :float)
    change_column(:accounting_cash_balances, :transaction_value, :float)
    change_column(:accounting_cash_balances, :total_payment_by_type, :float)

    # accounting_fixed_assets
    change_column(:accounting_fixed_assets, :value, :float)
    change_column(:accounting_fixed_assets, :scrap_value, :float)

    # accounting_fixed_asset_details
    change_column(:accounting_fixed_asset_details, :asset_values, :float)
    change_column(:accounting_fixed_asset_details, :depreciation_values, :float)
    change_column(:accounting_fixed_asset_details, :aje_values, :float)

    #accounting_purchase_balances
    change_column(:accounting_purchase_balances, :subtotal, :float)
    change_column(:accounting_purchase_balances, :discount, :float)
    change_column(:accounting_purchase_balances, :transaction_value, :float)
    change_column(:accounting_purchase_balances, :total_subtotal, :float)
    change_column(:accounting_purchase_balances, :final_total_purchase, :float)
    change_column(:accounting_purchase_balances, :total_discount, :float)
    change_column(:accounting_purchase_balances, :price, :float)
    change_column(:accounting_purchase_balances, :qty, :float)
    change_column(:accounting_purchase_balances, :disc_percentage, :float)

    # accounting_purchase_debit_credit_values
    change_column(:accounting_purchase_debit_credit_values, :value, :float)
    change_column(:accounting_purchase_debit_credit_values, :total_value, :float)

    # accounting_sale_balances
    change_column(:accounting_sale_balances, :subtotal, :float)
    change_column(:accounting_sale_balances, :discount, :float)
    change_column(:accounting_sale_balances, :total_subtotal, :float)
    change_column(:accounting_sale_balances, :final_total_sale, :float)
    change_column(:accounting_sale_balances, :total_discount, :float)
    change_column(:accounting_sale_balances, :transaction_value, :float)
    change_column(:accounting_sale_balances, :price, :float)
    change_column(:accounting_sale_balances, :qty, :float)
    change_column(:accounting_sale_balances, :disc_percentage, :float)

    # accounting_sale_debit_credit_values
    change_column(:accounting_sale_debit_credit_values, :value, :float)
    change_column(:accounting_sale_debit_credit_values, :total_value, :float)

    # trial_balances
    change_column(:trial_balances, :last_saldo, :float)
  end
end
