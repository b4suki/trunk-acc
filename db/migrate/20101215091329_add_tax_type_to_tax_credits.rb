class AddTaxTypeToTaxCredits < ActiveRecord::Migration
  def self.up
    add_column :tax_credits, :tax_type, :string
  end

  def self.down
    remove_column :tax_credits, :tax_type
  end
end
