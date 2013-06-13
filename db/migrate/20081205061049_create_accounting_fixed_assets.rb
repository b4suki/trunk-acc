class CreateAccountingFixedAssets < ActiveRecord::Migration
  def self.up
    create_table :accounting_fixed_assets do |t|
      t.date :date_purchase
      t.string :description
      t.float :value , :scrap_value
      t.integer :valuable_age, :purchase_balance_id, :qty
    end
  end

  def self.down
    drop_table(:accounting_fixed_assets)
  end
end
