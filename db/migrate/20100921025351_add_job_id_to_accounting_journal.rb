class AddJobIdToAccountingJournal < ActiveRecord::Migration
  def self.up
    add_column :accounting_journals, "job_id", :string
  end

  def self.down
    remove_column :accounting_journals, "job_id"
  end
end
