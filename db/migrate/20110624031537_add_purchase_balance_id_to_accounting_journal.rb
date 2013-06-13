class AddPurchaseBalanceIdToAccountingJournal < ActiveRecord::Migration
  def self.up
    add_column :accounting_journals, :sale_id, :integer
  end

  def self.down
    remove_column :accounting_journals, :sale_id
  end
end
