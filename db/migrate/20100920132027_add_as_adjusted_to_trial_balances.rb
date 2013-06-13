class AddAsAdjustedToTrialBalances < ActiveRecord::Migration
  def self.up
    add_column :trial_balances, "as_adjusted", :float, :limit => 50
  end

  def self.down
    remove_column(:trial_balances, "as_adjusted")
  end
end
