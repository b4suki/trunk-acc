class CreateAccountingCashes < ActiveRecord::Migration
  def self.up
    create_table :accounting_cashes do |t|
      t.integer :account_id
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_cashes
  end
end
