class AddColumnKursToPurchaseBalance < ActiveRecord::Migration
  def self.up
    add_column :accounting_purchase_balances, :kurs, :string
  end

  def self.down
    remove_column(:accounting_purchase_balances, :kurs)
  end
end
