class AddGroupToPurchaseValues < ActiveRecord::Migration
  def self.up
    add_column :accounting_purchase_debit_credit_values, :group_id, :string
  end

  def self.down
    remove_column(:accounting_purchase_debit_credit_values, :group_id)
  end
end
