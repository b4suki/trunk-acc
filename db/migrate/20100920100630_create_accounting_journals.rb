class CreateAccountingJournals < ActiveRecord::Migration
  def self.up
    create_table :accounting_journals do |t|
      t.string :evidence
      t.text :description
      t.integer :account_id
      t.integer :contra_account_id
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_journals
  end
end
