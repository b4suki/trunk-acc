class PrototypeItem < ActiveRecord::Base
  has_many :prototype_item_details, :dependent => :destroy
  has_many :items, :through => :prototype_item_details

  belongs_to :item

  validates_presence_of :item_id
end
