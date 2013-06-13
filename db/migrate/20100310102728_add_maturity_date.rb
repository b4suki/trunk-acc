class AddMaturityDate < ActiveRecord::Migration
  def self.up
    add_column :accounting_bank_balances, :maturity_date, :datetime
  end 
  
  def self.down
    remove_column(:accounting_bank_balances, :maturity_date)
  end
end
