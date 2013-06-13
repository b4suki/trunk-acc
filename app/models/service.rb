class Service < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 20

  has_many :service_details, :class_name => "AccountingSaleBalanceServiceDetail"
end
