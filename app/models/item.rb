class Item < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 20
  
  belongs_to :type
  belongs_to :unit
  has_many :products
  has_many :item_histories, :dependent => :destroy
  has_many :product_details, :dependent => :destroy
  has_many :prototype_items, :dependent => :destroy
  has_many :prototype_item_details, :dependent => :destroy
  has_many :pulsa_settings, :dependent => :destroy

  has_many :trans_items, :dependent => :destroy
  has_many :purchase_order_details
  has_many :purchase_balances, :class_name => "AccountingSaleBalanceDetail"
  has_many :sale_balance_details, :class_name => "AccountingSaleBalanceDetail"
  has_many :purchase_balance_details, :class_name => "AccountingPurchaseBalanceDetail"
  has_many :item_details, :dependent => :destroy

  validates_presence_of :name, :stock,:item_code, :price
  validates_numericality_of :price, :stock, :greater_than => 0

  before_create :calculate_total_value, :add_to_details

  def calculate_total_value
    self.total_value = self.stock * self.price
  end

  def self.sum_qty_and_total(id)
    data = []
    data << ItemDetail.sum("total",:conditions => ["item_id = #{id} AND qty != 0"])
    data << ItemDetail.sum("qty",:conditions => ["item_id = #{id} AND qty != 0"])
    self.find(id).update_attributes(:total_value => data[0], :stock => data[1])
  end

  def self.taking_item(trans_item)
    item_trans = TransItem.new(trans_item)
    item = self.find(trans_item[:item_id])
    qty = trans_item[:qty].to_i

    item.item_details.find(:all, :conditions => ["item_id = '#{item.id}' AND qty != 0"], :order => "sequence ASC").each do |detail|
      break if qty <= 0
      tmp = detail.qty > qty ? detail.qty - qty : 0
      qty -= detail.qty
      detail.update_attributes(:qty => tmp, :total => (tmp * detail.price.to_f) )
      item_trans.price = detail.price
      item_trans.qty = detail.qty
      item_trans.is_addition = false
    end
    self.sum_qty_and_total(item.id)
    return item_trans
  end

  def add_to_details
    item_details << ItemDetail.new(
      :qty => self.stock,
      :price => self.price,
      :total => self.stock * self.price,
      :purchasing_date => Time.now,
      :is_deleted => false
    )
  end

  def recalculate_stock_from_item_details(item, qty)
    tmp_qty = 0
    tmp_total = 0
    item.item_details.each do |item_detail|
      tmp_qty += item_detail.qty
      tmp_total += item_detail.total
    end
    item.update_attribute(:stock ,item.item_details.sum('qty') - qty)
    item.update_attribute(:total_value ,tmp_total)
  end
end
