class TransItemStatus < ActiveRecord::Base
  has_many :trans_items, :foreign_key => :status
end
