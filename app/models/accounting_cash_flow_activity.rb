class AccountingCashFlowActivity < ActiveRecord::Base
  has_many :categories, :class_name => "AccountingCashFlowCategory", :foreign_key => "activity_id"
end
