class CreateAccountingJournalValues < ActiveRecord::Migration
  def self.up
    create_table :accounting_journal_values do |t|
      t.integer :account_id
      t.float :value, :limit => 50
      t.integer :journal_id
      t.boolean :is_debit

      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_journal_values
  end
end
