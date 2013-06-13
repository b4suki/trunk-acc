class RenameColumnTermsOfPayment < ActiveRecord::Migration
  def self.up
      rename_column(:accounting_sale_balances, :terms_of_payment,:terms_of_payment_id)
  end

  def self.down
      rename_column(:accounting_sale_balances, :terms_of_payment_id,:terms_of_payment)
  end
end
