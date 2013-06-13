module Accounting::AdjustmentBalancesHelper
  def create_adjustment_balances(purchase,row)       
    ret =""
    ret << "<td style=\"width:40px;text-align:right;\">#{row}</td>" #nomor
    ret << "<td style=\"width:200px;text-align:right;\">#{purchase.accounting_fixed_asset.date_purchase.strftime("%d-%b-%Y")}</td>" #Tanggal Perolehan
    ret << "<td style=\"width:400px;text-align:right;\">#{purchase.accounting_fixed_asset.description}</td>" #Nama Aktiva Tetap
    ret << "<td style=\"width:180px;text-align:right;\">#{purchase.accounting_fixed_asset.value}</td>" #Nilai Perolehan 
    ret << "<td style=\"width:180px;text-align:right;\">#{purchase.accounting_fixed_asset.scrap_value}</td>" #Nilai Sisa    
    ret << "<td style=\"width:180px;text-align:right;\">#{purchase.accounting_fixed_asset.valuable_age}</td>" #Nilai Sisa    
  end
  
   def formula_depreciation_reverse_aje(detail, status)      
    bol = false
    values = 0
    conditions = []
    cek =  AdjustmentAccount.find(:first, :conditions => ['account_id = ?', detail.account_id])
    bol = cek.debit_credit
    if status
      conditions << "month(transaction_date) = #{$month}"
      conditions << "Year(transaction_date) = #{$year}"
      conditions << "fixed_asset_id = #{detail.fixed_asset_id}"
      conditions << "account_id = #{detail.account_id}"
      conditions = conditions.join(' AND ')
    end  
        
    fixedDetails = AccountingFixedAssetDetail.find(:all, :conditions => conditions)      
    fixedDetails.each do |fixed|
      if fixed.transaction_date != $month  || fixed.transaction_date.strftime('%d') <= "15" 
        values += ((fixed.accounting_fixed_asset.value - fixed.accounting_fixed_asset.scrap_value) *(1.to_f/fixed.accounting_fixed_asset.valuable_age.to_f))*0.083333            
      end
    end  
    x_values = ""           
    if bol == true
      $TOTAL_FIXED_ASSETS_CREDIT = $TOTAL_FIXED_ASSETS_CREDIT + values
     x_values << "<td>&nbsp;</td>"     
     x_values << "<td align='right'>#{format_currency(values)}</td>"
    else           
     $TOTAL_FIXED_ASSETS_DEBIT = $TOTAL_FIXED_ASSETS_DEBIT + values 
     x_values << "<td align='right'>#{format_currency(values)}</td>"
     x_values << "<td>&nbsp;</td>" 
    end
    x_values
  end
  
  def format_currency_aje(number)
    toggle_value = nil
    toggle_value = (number * -1) if number < 0
    value = number_to_currency(toggle_value || number, :unit => "", :delimiter => ",", :separator => ".", :precision => 2)
    if toggle_value
      "<font color='red'>(#{value})</font>"
    else
      value
    end
  end
  
  def get_total_aje
    total = {}
    total = {:test => total() , :test2 => total()}
  end
  
  def total(account)
    conditions = []
    conditions << "account_id = #{account.account_id}"
    conditions << "MONTH(transaction_date) = #{$month}"
    conditions << "YEAR(transaction_date) = #{$year}"
    conditions = conditions.join(" AND ")
    
    AccountingFixedAssetDetail.find(:all,:conditions => conditions)
  end    

  def selected_account_adjustment(adjustment_balance) 
    adjustment_balance.contra_account_id.nil? ? "" : adjustment_balance.accounting_account.code.to_s+"   "+adjustment_balance.accounting_account.description.to_s
  end  
end
