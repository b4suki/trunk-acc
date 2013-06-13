class PulsaCustomer < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 20

  belongs_to :customer
  belongs_to :car

  has_many :detail_pulsa_customers
  has_many :pulsa_customer_payment_dates

  after_create :generate_date
  after_destroy :delete_dates
  
  def generate_date
    increment = 0
#    date_hash = {}
    if self.package > 0
      for increment in 1..self.package
        payment_date = PulsaCustomerPaymentDate.new(:payment_date => self.date_install + increment.month, :payment_status => 'false', :pulsa_customer_id => self.id )
        payment_date.save
      end
      #      date_hash.each do |d|
      #        payment_date = PulsaCustomerPaymentDate.new(d)
      #        payment_date.save
      #      end
    end
  end

  def delete_dates
    payments = self.pulsa_customer_payment_dates.find(:all,:conditions => ["pulsa_customer_id = ?", self.id])
    payments.each do |payment|
      payment.destroy
    end
  end
end
