class ItemDetail < ActiveRecord::Base
  belongs_to :item
  belongs_to :purchase_balance, :class_name => "AccountingPurchaseBalance", :foreign_key => "purchase_balance_id"

  before_create :generate_sequence

  def generate_sequence
    last_record = ItemDetail.find(:first, :conditions => "item_id='#{self.item_id}'", :order => "sequence DESC")
    new_sequence = last_record.nil? ? 1 : last_record.sequence + 1
    self.sequence = new_sequence
  end

  def self.get_total_value_from_item(item_id)
    details = ItemDetail.find(:all, :conditions => "item_id='#{item_id}'")
    details.sum(&:total)
  end
end
