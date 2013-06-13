class AddLastSaldoToPulsaCustomers < ActiveRecord::Migration
  def self.up
    add_column :pulsa_customers, :last_saldo, :float
  end

  def self.down
    remove_column :pulsa_customers, :last_saldo
  end
end
