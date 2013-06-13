class CreateAccountingCashFlowCategories < ActiveRecord::Migration
  def self.up
    create_table :accounting_cash_flow_categories do |t|
      t.string :title
      t.integer :activity_id
      t.boolean :is_cash_receipt

      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_cash_flow_categories
  end
end
