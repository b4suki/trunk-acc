class PrototypeItemDetail < ActiveRecord::Base
  belongs_to :prototype_item
  belongs_to :item

  validates_presence_of :item_id
end
