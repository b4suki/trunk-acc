class CreateAdjustmentAccounts < ActiveRecord::Migration
  def self.up
    create_table :adjustment_accounts do |t|
      t.column :account_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :adjustment_accounts
  end
end
