class AddPaymentProcedure < ActiveRecord::Migration
 def self.up
    add_column :accounting_cash_balances, :payment_procedure, :string
  end 
  
  def self.down
    remove_column(:accounting_cash_balances, :payment_procedure)
  end
end
