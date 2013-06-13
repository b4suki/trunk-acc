class AddColumnDescriptionAndPositionToAccountingSaleBalanceDetail < ActiveRecord::Migration
  def self.up
    add_column "accounting_sale_balance_details", "description", :string
    add_column "accounting_sale_balance_details", "position", :string
  end

  def self.down
    remove_column("accounting_sale_balance_details", "description")
    remove_column("accounting_sale_balance_details", "position")
  end
end
