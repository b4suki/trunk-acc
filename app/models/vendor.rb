class Vendor < ActiveRecord::Base 
  has_many :accounting_purchase_balances
  has_many :accounting_mutations , :foreign_key => 'vendor_customer_id'
  has_many :tax_credits

  #validates_length_of :phone, :is => 10, :message => 'must be 10 digits, excluding special characters such as spaces and dashes. No extension or country code allowed.', :if => Proc.new{|o| !o.phone.blank?}
  #validates_length_of :fax, :is => 10, :message => 'must be 10 digits, excluding special characters such as spaces and dashes. No extension or country code allowed.', :if => Proc.new{|o| !o.fax.blank?}
  validates_numericality_of :phone, :fax
  validates_length_of :name, :maximum => 128, :message => "Nama Terlalu Panjang"
  validates_presence_of :name, :address, :phone, :fax
  validates_length_of :phone, :maximum => 12, :message => "No Telp Terlalu Panjang"
  validates_length_of :fax, :maximum => 12, :message => "No Telp Terlalu Panjang"  
 # validates_uniqueness_of :phone, :fax
end
