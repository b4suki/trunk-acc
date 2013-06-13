class AddJournalIdToAccountingMutations < ActiveRecord::Migration
  def self.up
    add_column :accounting_mutations, :journal_id, :integer
  end

  def self.down
    remove_column :accounting_mutations, :journal_id
  end
end
