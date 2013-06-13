class CreateAccountingSaleSignatures < ActiveRecord::Migration
  def self.up
    create_table :accounting_sale_signatures do |t|
      t.string "company_name"
      t.string "signatory"
      t.string "position"
      t.boolean "active"
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_sale_signatures
  end
end
