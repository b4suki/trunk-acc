class CreateAccountingReconciliationDetailValues < ActiveRecord::Migration
  def self.up
    create_table :accounting_reconciliation_detail_values , :force => true do |t|
      t.integer :bank_reconciliation_id
      t.integer :reconciliation_details_id
      t.float :value
      t.float :total_value
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_reconciliation_detail_values
  end
end
