class ChangeColumnAmountInTaxCredits < ActiveRecord::Migration
  def self.up
    change_column :tax_credits, :amount, :float, :limit => 50
  end

  def self.down
  end
end
