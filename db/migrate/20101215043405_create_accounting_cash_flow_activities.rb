class CreateAccountingCashFlowActivities < ActiveRecord::Migration
  def self.up
    create_table :accounting_cash_flow_activities do |t|
      t.string :name

      t.timestamps
    end
    AccountingCashFlowActivity.create(:name => "operasi")
    AccountingCashFlowActivity.create(:name => "investasi")
    AccountingCashFlowActivity.create(:name => "pendanaan")
  end

  def self.down
    drop_table :accounting_cash_flow_activities
  end
end
