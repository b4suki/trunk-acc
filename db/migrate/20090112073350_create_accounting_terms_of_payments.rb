class CreateAccountingTermsOfPayments < ActiveRecord::Migration
  def self.up
    create_table :accounting_terms_of_payments do |t|
      t.string :name, :description
      t.integer :days
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_terms_of_payments
  end
end
