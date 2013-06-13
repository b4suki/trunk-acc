class RenamePaymentProsedure < ActiveRecord::Migration
   def self.up
    rename_column(:accounting_cash_balances, :payment_procedure, :payment_procedure_id)
    change_column :accounting_cash_balances, :payment_procedure_id, :integer
  end

  def self.down
    rename_column(:accounting_cash_balances, :payment_procedure_id, :payment_procedure)
    change_column :accounting_cash_balances, :payment_procedure_id, :string
  end
end
