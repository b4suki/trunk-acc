class AddColumnToVendorAndCustomer < ActiveRecord::Migration
  def self.up
      add_column(:vendors, :rek_no, :string)
      add_column(:vendors, :npwp, :string)
      add_column(:customers,:rek_no, :string)
      add_column(:customers, :npwp, :string)
  end

  def self.down
      remove_columns(:vendors, :rek_no, :npwp)
      remove_columns(:customers, :npwp, :string)
  end
end
