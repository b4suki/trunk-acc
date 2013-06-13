class ExchangeRate < ActiveRecord::Base
  validates_presence_of :rate
  validates_numericality_of :rate
  
  def self.get_all_list_exchange
    find(:all)
  end
  
  def self.get_by_id(id)
    find(id)
  end
  
end
