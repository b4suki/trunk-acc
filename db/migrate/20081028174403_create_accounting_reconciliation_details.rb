class CreateAccountingReconciliationDetails < ActiveRecord::Migration
  def self.up
    create_table :accounting_reconciliation_details do |t|
      t.string :name
      t.boolean :debit, :default => false
      t.boolean :credit, :default => false
      t.boolean :company, :default => false
      t.boolean :bank, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_reconciliation_details
  end
end
