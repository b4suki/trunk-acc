class CreateAccountingSaleBalanceDetails < ActiveRecord::Migration
  def self.up
    create_table :accounting_sale_balance_details do |t|
      t.string :product_name
      t.float :qty, :price, :discount
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_sale_balance_details
  end
end
