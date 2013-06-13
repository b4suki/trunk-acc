class CreateAccountingAccountClassifications < ActiveRecord::Migration
  def self.up
    create_table :accounting_account_classifications do |t|
      t.string "name"
      t.boolean "is_debit"
      t.timestamps
    end

    AccountingAccountClassification.create(:id => "1", :name => "Harta", :is_debit => true)
    AccountingAccountClassification.create(:id => "2", :name => "Utang", :is_debit => false)
    AccountingAccountClassification.create(:id => "3", :name => "Modal", :is_debit => false)
    AccountingAccountClassification.create(:id => "4", :name => "Pendapatan", :is_debit => false)
    AccountingAccountClassification.create(:id => "5", :name => "Beban", :is_debit => true)
  end

  def self.down
    drop_table :accounting_account_classifications
  end
end
