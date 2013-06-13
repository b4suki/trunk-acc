class AddCustomerIdToTaxCredits < ActiveRecord::Migration
  def self.up
    add_column :tax_credits, :customer_id, :integer
  end

  def self.down
    remove_column :tax_credits, :customer_id
  end
end
