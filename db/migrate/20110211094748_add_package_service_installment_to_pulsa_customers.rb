class AddPackageServiceInstallmentToPulsaCustomers < ActiveRecord::Migration
  def self.up
    add_column :pulsa_customers, :package, :integer
    add_column :pulsa_customers, :service, :float
    add_column :pulsa_customers, :installment, :float
  end

  def self.down
    remove_column :pulsa_customers, :installment
    remove_column :pulsa_customers, :service
    remove_column :pulsa_customers, :package
  end
end
