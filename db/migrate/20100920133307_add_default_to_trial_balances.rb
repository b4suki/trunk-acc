class AddDefaultToTrialBalances < ActiveRecord::Migration
  def self.up
    change_column_default(:trial_balances, :last_saldo, 0)
    change_column_default(:trial_balances, :as_adjusted, 0)
  end

  def self.down
    change_column_default(:trial_balances, :last_saldo, nil)
    change_column_default(:trial_balances, :as_adjusted, nil)
  end
end
