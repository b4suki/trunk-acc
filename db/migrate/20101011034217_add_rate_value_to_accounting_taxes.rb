class AddRateValueToAccountingTaxes < ActiveRecord::Migration
  def self.up
    add_column :accounting_taxes, :rate_value, :float
  end

  def self.down
    remove_column :accounting_taxes, :rate_value
  end
end
