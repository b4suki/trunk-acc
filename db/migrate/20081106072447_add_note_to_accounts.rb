class AddNoteToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounting_accounts, :notes, :text
  end

  def self.down
    remove_column :accounting_accounts, :notes
  end
end
