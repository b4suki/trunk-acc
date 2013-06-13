class TransItem < ActiveRecord::Base

  acts_as_state_machine :initial => :request
  #acts_as_state_machine :column => 'state'
  belongs_to :trans_item_status, :foreign_key => :status
  belongs_to :product
  belongs_to :item
  before_save :update_item_detail

  state :order
  state :request
  state :received
  state :pengambilan
  state :readyorder

  event :ambil do
    transitions :from => :request, :to => :pengambilan
  end

  event :ready do
    transitions :from => :request, :to => :readyorder
  end

  event :cancelready do
    transitions :from => :readyorder, :to => :request
  end


  event :ordering do
    transitions :from => :readyorder, :to => :order
  end

  event :receiving do
    transitions :from => :order, :to => :received
  end
  

  #belongs_to :item
  belongs_to :user
  belongs_to :role
  has_many :trans_items
  validates_presence_of :qty, :description
  #belongs_to :trans_item_status, :foreign_key => :status

  def status_name
    status.name if status
  end

  def status_name=(name)
    self.status = TransItemStatus.find_or_create_by_name(name) unless name.blank?
  end

  def update_item_detail
    unless self.is_addition
      order = "ASC" if item.inventory_method == "FIFO"
      order = "DESC" if item.inventory_method == "LIFO"
      qty = self.qty
      item.item_details.find(:all, :conditions =>["is_deleted = 0"], :order => "sequence #{order}").each do |item_detail|
        break if qty <= 0
        tmp = item_detail.qty > qty ? item_detail.qty - qty : 0
        qty -= item_detail.qty
        item_detail.update_attribute :is_deleted, true if tmp <= 0
        item_detail.update_attribute :qty, tmp
        item_detail.update_attribute :total, item_detail.qty * item_detail.price
      end
      item.update_attribute(:total_value, ItemDetail.get_total_value_from_item(item.id))
    end
  end

end
