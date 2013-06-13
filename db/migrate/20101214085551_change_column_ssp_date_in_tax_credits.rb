class ChangeColumnSspDateInTaxCredits < ActiveRecord::Migration
  def self.up
    remove_column("tax_credits", "SSP_date")
    add_column "tax_credits", "ssp_date", :date
  end

  def self.down
    remove_column("tax_credits", "ssp_date")
    add_column "tax_credits", "SSP_date", :date
  end
end
