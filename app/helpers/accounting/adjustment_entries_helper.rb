module Accounting::AdjustmentEntriesHelper
  def create_adjustment_purchase_balances(purchase,row)     
    total_aktiva(purchase)
    ret =""
    ret << "<tr class =#{cycle("grid_2","grid_3")}>"
    ret << "<td align='right' style=\"width:40px;\">#{row}</td>" #nomor
    ret << "<td align='right' style=\"width:200px;\">#{purchase.accounting_fixed_asset.date_purchase.strftime("%d-%b-%Y")}</td>" #Tanggal Perolehan
    ret << "<td align='right' style=\"width:400px;\">#{purchase.accounting_fixed_asset.description}</td>" #Nama Aktiva Tetap
    ret << "<td align='right' style=\"width:180px;\">#{format_currency(purchase.accounting_fixed_asset.value)}</td>" #Nilai Perolehan 
    ret << "<td align='right' style=\"width:180px;\">#{format_currency(purchase.accounting_fixed_asset.scrap_value) if purchase.accounting_fixed_asset.scrap_value != nil}</td>" #Nilai Sisa    
    ret << "<td align='right' style=\"width:180px;\">#{purchase.accounting_fixed_asset.valuable_age.to_i if purchase.accounting_fixed_asset.valuable_age != nil}</td>" #Nilai Sisa    
    ret << "<td align='right' style=\"width:100px;\">#{format_currency(check_month_before(purchase)[1].to_f) if check_month_before(purchase)[1] != nil}</td>" #saldo bulan sebelum
    ret << "<td align='right' style=\"width:100px;\">#{format_currency(check_current_month(purchase)[0].to_f) if check_current_month(purchase)[0] != nil}</td>" #penambahan
    ret << "<td align='right' style=\"width:100px;\">#{format_currency(check_current_month(purchase)[1].to_f) if check_current_month(purchase)[1] != nil}</td>" #pengurangan
    ret << "<td align='right' style=\"width:100px;\">#{format_currency(check_current_month(purchase)[3].to_f) if check_current_month(purchase)[3] != nil}</td>"#saldo_bulan ini
    ret << "<td align='right' style=\"width:100px;\">#{format_currency(check_month_before(purchase)[2].to_f) if check_month_before(purchase)[2] != nil}</td>"#depreciation sebelum 
    ret << "<td align='right' style=\"width:100px;\">#{format_currency(check_current_month(purchase)[5].to_f) if check_current_month(purchase)[5] != nil}</td>"# penambahan
    ret << "<td align='right' style=\"width:100px;\">#{format_currency(check_current_month(purchase)[6].to_f) if check_current_month(purchase)[6] != nil}</td>"#pengurananga
    ret << "<td align='right' style=\"width:100px;\">#{format_currency(check_current_month(purchase)[7].to_f) if check_current_month(purchase)[7] != nil}</td>"#saldo terakhir
    ret << "<td align='right' style=\"width:50px;\">#{format_currency(check_current_month(purchase)[8].to_f) if check_current_month(purchase)[8] != nil}</td>"   
    ret << "</tr>"            
  end
  
  def check_current_month(obj)      
    value = []
    if obj
      if check_month_before(obj)[1].nil?
        value[0] = obj.asset_values     
      else
        value[0] = ""
      end
      value[1] = ""
      value[3] = obj.asset_values
      value[4] = "dep_before"
      value[5] = if obj.depreciation_values !=0
             formula_depreciation(obj)
      else
        "0"
      end
      value[6] = ""
      value[7] = obj.depreciation_values
      value[8] = obj.aje_values
    end
    value
  end
  
  def check_month_before(obj)    
    before = false
    if $month == "1"
      $month = "13"
      $year = ($year.to_i - 1).to_s
      before = true
    end 
    a = []
    @check = AccountingFixedAssetDetail.find(:first, :conditions => ["month(transaction_date)= ? and fixed_asset_id = ? ",($month.to_i-1), obj.fixed_asset_id])      
    if @check
      a[1] = @check.aje_values
      a[2] = @check.depreciation_values     
    end
    $month = "1" if before
    $year = ($year.to_i + 1).to_s if before
    a
  end
  
  def total_aktiva(purchase)
    check_month_before(purchase)[1] ? $TOTAL_ASSET_BEFORE += check_month_before(purchase)[1].to_d : 0
    check_current_month(purchase)[0] ?  $TOTAL_ASSET_ADD  += check_current_month(purchase)[0].to_d : 0
    check_current_month(purchase)[1] ?  $TOTAL_ASSET_MINUS  += check_current_month(purchase)[1].to_d : 0
    check_current_month(purchase)[3] ?  $TOTAL_ASSET_CURRENT  += check_current_month(purchase)[3].to_d : 0
    check_month_before(purchase)[2]? $TOTAL_DEPRECIATION_BEFORE += check_month_before(purchase)[2].to_d : 0
    check_current_month(purchase)[5] ?  $TOTAL_DEPRECIATION_ADD  += check_current_month(purchase)[5].to_d : 0
    check_current_month(purchase)[6] ?  $TOTAL_DEPRECIATION_MINUS  += check_current_month(purchase)[6].to_d : 0
    check_current_month(purchase)[7] ?  $TOTAL_DEPRECIATION_CURRENT  += check_current_month(purchase)[7].to_d : 0
    check_current_month(purchase)[8] ?  $TOTAL_VALUES  += check_current_month(purchase)[8].to_d : 0    
    purchase.accounting_fixed_asset.value ? $TOTAL_COST += purchase.accounting_fixed_asset.value : 0
    purchase.accounting_fixed_asset.scrap_value ? $TOTAL_SCRAP += purchase.accounting_fixed_asset.scrap_value : 0
    
    check_month_before(purchase)[1] ? $TOTAL_ASSET_BEFORE_ALL += check_month_before(purchase)[1].to_d : 0
    check_current_month(purchase)[0] ?  $TOTAL_ASSET_ADD_ALL  += check_current_month(purchase)[0].to_d : 0
    check_current_month(purchase)[1] ?  $TOTAL_ASSET_MINUS_ALL  += check_current_month(purchase)[1].to_d : 0
    check_current_month(purchase)[3] ?  $TOTAL_ASSET_CURRENT_ALL  += check_current_month(purchase)[3].to_d : 0
    check_month_before(purchase)[2]? $TOTAL_DEPRECIATION_BEFORE_ALL += check_month_before(purchase)[2].to_d : 0
    check_current_month(purchase)[5] ?  $TOTAL_DEPRECIATION_ADD_ALL  += check_current_month(purchase)[5].to_d : 0
    check_current_month(purchase)[6] ?  $TOTAL_DEPRECIATION_MINUS_ALL  += check_current_month(purchase)[6].to_d : 0
    check_current_month(purchase)[7] ?  $TOTAL_DEPRECIATION_CURRENT_ALL  += check_current_month(purchase)[7].to_d : 0
    check_current_month(purchase)[8] ?  $TOTAL_VALUES_ALL  += check_current_month(purchase)[8].to_d : 0               
    purchase.accounting_fixed_asset.value ? $TOTAL_COST_ALL += purchase.accounting_fixed_asset.value.to_d : 0
    purchase.accounting_fixed_asset.scrap_value ? $TOTAL_SCRAP_ALL += purchase.accounting_fixed_asset.scrap_value.to_d : 0
  end
 
  
  def cek_button_generate
    value = false
    before = false
    cek = false    
    conditions = []
    conditions << "month(transaction_date) = #{$month}"
    conditions << "year(transaction_date) = #{$year}"
    conditions = conditions.join(" and ") 
    
    if $month == "1"
      $month = "13"
      $year = ($year.to_i - 1).to_s
      before = true
    end 
    
    unless AccountingFixedAssetDetail.find(:all, :conditions => conditions).blank?      
      value = true 
      cek = true    
    end
    
    if cek == false     
      unless AccountingFixedAssetDetail.find(:all, :conditions => ["month(transaction_date) = ? and year(transaction_date) = ?",$month.to_i-1,$year]).blank?    
        value = false        
      else
        value = true
      end   
    end
    $month = "1" if before
    $year = ($year.to_i + 1).to_s if before   
    value
  end
  
end
