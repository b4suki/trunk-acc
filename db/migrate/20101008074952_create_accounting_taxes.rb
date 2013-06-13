class CreateAccountingTaxes < ActiveRecord::Migration
  def self.up
    create_table :accounting_taxes do |t|
      t.string :account_type
      t.string :description
      t.integer :account_id
      t.float :rate
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_taxes
  end
end
