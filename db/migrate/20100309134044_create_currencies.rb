class CreateCurrencies < ActiveRecord::Migration
  def self.up
    create_table :currencies do |t|
      t.string :name
    end

#    add_column :accounting_purchase_balances, :currency_id, :integer
#    add_column :accounting_purchase_balances, :kurs,     :string
    execute "INSERT INTO `currencies` (`name`) VALUES
            ('Rupiah'),
            ('Dollar');"
  end

  def self.down
    drop_table :currencies
  end
end
