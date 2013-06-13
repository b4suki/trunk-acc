class AddCurencyIdAndKurs < ActiveRecord::Migration
  def self.up
    add_column :accounting_sale_balances, :currency_id, :integer
    add_column :accounting_sale_balances, :kurs, :float
  end

  def self.down
    remove_column(:accounting_sale_balances, :currency_id)
    remove_column(:accounting_sale_balances, :kurs)
  end
end
