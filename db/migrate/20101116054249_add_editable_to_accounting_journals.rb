class AddEditableToAccountingJournals < ActiveRecord::Migration
  def self.up
    add_column :accounting_journals, :editable, :boolean, :default => true
  end

  def self.down
    remove_column :accounting_journals, :editable
  end
end
