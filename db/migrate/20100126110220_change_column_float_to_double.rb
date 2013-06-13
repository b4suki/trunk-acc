class ChangeColumnFloatToDouble < ActiveRecord::Migration
  def self.up
    #float :limit => 25   (yields a double)
    change_column :items, :price, :float, :size => 20
#    change_column :purchase_orders, :total_order, :float, :size => 20
#    change_column :purchase_orders, :discount, :float, :size => 20
#    change_column :purchase_order_details, :price, :float, :size => 20
#    change_column :purchase_order_details, :subtotal, :float, :size => 20
#    change_column :purchase_order_details, :discount,  :float, :size => 20
  end

  def self.down
    change_column :items, :price, :float
  end
end
