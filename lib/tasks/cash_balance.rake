task :cash_balance => :environment do   
  1.upto(12) do |x|
    cash_balances = AccountingCashBalance.find(:all, :conditions => ["month(created_at) = #{x} and bkk is not null"], :order => "created_at asc")
    cash_balances.each_with_index do |cash_balance, index|
      two_digit_month = cash_balance.created_at.strftime("%m")
      count = index < 10 ? "0"+(index + 1).to_s : index.to_s
      count = count+two_digit_month.to_s
      cash_balance.update_attribute(:bkk, count)      
    end
  end
  
  1.upto(12) do |x|
    cash_balances = AccountingCashBalance.find(:all, :conditions => ["month(created_at) = #{x}  and bkm is not null"], :order => "created_at asc")
    cash_balances.each_with_index do |cash_balance, index|
      two_digit_month = cash_balance.created_at.strftime("%m")
      count = index < 10 ? "0"+(index + 1).to_s : index.to_s
      count = count+two_digit_month.to_s
      cash_balance.update_attribute(:bkm, count)      
    end
  end
end
