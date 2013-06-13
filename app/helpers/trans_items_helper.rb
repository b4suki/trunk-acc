module TransItemsHelper
  def options_for_item_transaction
    options = TransItemStatus.find(:all).collect {|s| [s.name, s.id]}
    return options
  end

  def set_status_trans(status)
    ret = ""    
    case status
    when 1
      then ret = "Pengambilan"
    when 2 then
      ret = "Purchase Request"
    when 3 then      
      ret = "Ready Purchase Order"
    when 4 then
      ret = "Created Purchase Order"
    when 5 then
      ret = "Received"
    when 6 then
      ret = "Request"
    end
    return ret    
  end

  def options_for_stat    
    options = TransItemStatus.find(:all).collect {|s| [s.name, s.id]}
    return options
  end

  def month_names_before(index)
    if index == "1" || index == "13"
      index = "12"
    end
    month = ["JANUARI", "FEBRUARI", "MARET", "APRIL", "MEI", "JUNI", "JULI", "AGUSTUS", "SEPTEMBER", "OKTOBER", "NOVEMBER", "DESEMBER"]
    return month[index.to_i - 1]
  end

  def get_first_stock(item, date)
    ret = ''
    date = date ? Time.mktime(date[:year], date[:month], 1, 0, 0, 0, 0) : Time.now
    previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}
    history_item = item.item_histories.find(:first, :conditions => ["MONTH(last_date) = #{previous_date[:month]} AND YEAR(last_date) = #{previous_date[:year]}"])
    stock_first = history_item ? history_item.last_stock : 0
    if $stat != nil && $stat != ""
      qty_plus = item.trans_items.sum('qty', :conditions =>["MONTH(created_at) = #{$month} AND YEAR(created_at) = #{$year} AND is_addition = 1 AND status = '#{$stat}'"])
      qty_min = item.trans_items.sum('qty', :conditions =>["MONTH(created_at) = #{$month} AND YEAR(created_at) = #{$year} AND is_addition = 0 AND status = '#{$stat}'"])
    else
      qty_plus = item.trans_items.sum('qty', :conditions =>["MONTH(created_at) = #{$month} AND YEAR(created_at) = #{$year} AND is_addition = 1"])
      qty_min = item.trans_items.sum('qty', :conditions =>["MONTH(created_at) = #{$month} AND YEAR(created_at) = #{$year} AND is_addition = 0"])
    end
     ret << "<th>#{stock_first}</th>"
     ret << "<th>#{qty_plus}</th>"
     ret << "<th>#{qty_min}</th>"
     ret << "<th>#{(stock_first + qty_plus ) - qty_min}</th>"
  end
end
