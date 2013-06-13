class CreateAccountingSaleBalanceServiceDetails < ActiveRecord::Migration
  def self.up
    create_table :accounting_sale_balance_service_details do |t|
      t.integer :sale_balance_id
      t.integer :service_id
      t.float :qty
      t.float :price, :limit => 50
      t.float :subtotal, :limit => 50

      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_sale_balance_service_details
  end
end
