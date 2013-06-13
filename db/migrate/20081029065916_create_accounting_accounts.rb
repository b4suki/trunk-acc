class CreateAccountingAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounting_accounts do |t|
      t.integer :code_a, :code_b, :code_c, :code_d, :code_e, :code, :parent_id
      t.string :description
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_accounts
  end
end
