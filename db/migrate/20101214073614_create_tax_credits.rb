class CreateTaxCredits < ActiveRecord::Migration
  def self.up
    create_table :tax_credits do |t|
      t.date :SSP_date
      t.string :evidence
      t.integer :vendor_id
      t.float :amount, :default => 0
      t.integer :manual_journal_id
      t.timestamps
    end
  end

  def self.down
    drop_table :tax_credits
  end
end