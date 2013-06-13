class CreateAccountingPurchaseBalanceDetails < ActiveRecord::Migration
  def self.up
    create_table :accounting_purchase_balance_details do |t|
      t.integer :purchase_balance_id
      t.string :product_name
      t.float :qty
      t.float :price
      t.float :discount
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_purchase_balance_details
  end
end
