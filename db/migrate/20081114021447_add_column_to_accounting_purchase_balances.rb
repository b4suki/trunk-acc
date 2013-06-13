class AddColumnToAccountingPurchaseBalances < ActiveRecord::Migration
  def self.up
    add_column :accounting_purchase_balances, :price , :float#, :default => 0
    add_column :accounting_purchase_balances, :qty , :float#, :default => 0
    add_column :accounting_purchase_balances, :disc_percentage , :float#,:limit => 100, :default =>0 
    add_column :accounting_purchase_balances, :po_out , :string
    rename_column(:accounting_purchase_balances, :purchase_debit_kredit_id, :purchase_debit_credit_id)
  end

  def self.down
    remove_column(:accounting_purchase_balances, :price, :qty, :disc_percentage,:po_out)
    rename_column(:accounting_purchase_balances, :purchase_debit_credit_id, :purchase_debit_kredit_id)
  end
end
