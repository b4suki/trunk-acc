class ChangeColumnPaymentOnPurchaseBalances < ActiveRecord::Migration
  def self.up
    rename_column :accounting_purchase_balances, :terms_of_payment, :terms_of_payment_id
    change_column :accounting_purchase_balances, :terms_of_payment_id, :integer
  end

  def self.down
    rename_column :accounting_purchase_balances, :terms_of_payment_id, :terms_of_payment
    change_column :accounting_purchase_balances, :terms_of_payment_id, :string
  end
end
