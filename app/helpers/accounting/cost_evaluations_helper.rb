module Accounting::CostEvaluationsHelper
  def year_of_end()
    return   year = ("2000".."2030").to_a.collect{|category| [category, category]}
  end

  def opt_classifications(conditions)
    ret = ''
    AccountingAccountClassification.find(:all).each_with_index do |classification, index|
      ret << check_box_tag("classification[option_#{classification.id}]", classification.id, conditions ==[] ? true : opt_check(conditions, classification.id.to_s) , :id => "classification_id_#{index + 1}")
      ret << label_tag("classification_id_#{index + 1}", classification.name.to_s.titleize)
      ret << space(4)
    end
    ret
  end

  def opt_check(conditions, classification)
    check = false
    conditions.each { |i|  check = true if classification == i}
    return check
  end

  def get_value_conditions(conditions)
    ret = {}
    conditions.each { |i|  ret.update("option_#{i}" => i) }
    return ret
  end

  def generate_table_evaluations(group, depth)
    costs = {}
    $row = 0 
    table = ""    
    if group.code_a.to_s != '4'
      costs = AccountingAccount.find(:all, :conditions => ["code_a = ? and code_b = ?",group.code_a, group.code_b])
    else
      costs = AccountingAccount.find(:all, :conditions => ["code_a = ?" ,group.code_a])
    end    
    $row = costs.size
    costs.each_with_index do |cost, i|
      if i != 0
        table << "<tr class = #{cycle("grid_2","grid_3")} >"
        table << "<td> </td>"
        if cost.code.to_s[cost.code.to_s.size - 1,cost.code.to_s.size] == "0"
          table << "<td style = 'font-weight:bold;'> #{cost.code} </td>"
          table << "<td style = 'font-weight:bold;'> #{cost.description} </td>"        
        else
          table << "<td> </td>"
          table << "<td> #{cost.code} "
          table << " #{cost.description} </td>"
        end
        table <<  sum_next_account_code(cost,$year,depth)
        table << "<td>
          #{$TOTAL_YEARS}
        </td>" #2007
        table << "<script>
                    var s = parseFloat($('sum-year-up-#{depth}').innerHTML) + #{$TOTAL_YEARS.to_f};
                     $('sum-year-up-#{depth}').innerHTML = s;
                  </script>" 
        table << "<td id=\"#{depth}-#{i}\"/>0</td>
           <script>$('#{depth}-#{i}').value = 'test'</script>
          <script>
            var y = parseFloat($('sum-year-up-0').innerHTML);            
            var tmp = (parseFloat(#{$TOTAL_YEARS}) / parseFloat(y))* 100;             
            if(y == 0){tmp = 0;}
            $('#{depth}-#{i}').innerHTML = parseFloat(tmp);
            $('#{depth}-#{i}').innerHTML = $('#{depth}-#{i}').innerHTML + '%';        
          </script>"
        table << "</tr>"       
      end
    end
    table
  end

  #============SUM FOR FIRST ACCOUNT CODE===============#
  def sum_first_account_code(year, depth)
    table = ""
    1.upto(12) do |x|                  
      table << "<td style='width:100px; text-align:right;'>"
      table << "<div style='color: red;' id=\"sum-#{x}-#{depth}\">0</div>"
      table << "</td>"
    end
    table << "<td>
      <div style='color: red;' id =\"sum-year-up-#{depth}\">0</div>
      </td>"#2007    
    table << "<td>       
       <div style='color: red;' id = \"common-year-#{depth}\">0</div>
       <script>
        var x = $('sum-year-up-#{depth}').innerHTML;
        var y = $('sum-year-up-0').innerHTML;
        var percent = (parseFloat(x) / parseFloat(y)) * 100;
        if (y == 0){percent = 0;}
        $('common-year-#{depth}').innerHTML = percent.toString() + '%';           
       </script>      
    </td>"
    table
  end
  
  def last_account_code(size, depth)
    table = ""
    if size == depth+1
      table << "<td>&nbsp;</td>"
      table << "<td>81100</td>      
                <td>Ikhtisar Laba Rugi</td>"
      1.upto(12) do |x|  
        table << "<td align='right'>
                    <div style='color: red;' id= \"sum-last-#{x}\">0</div>                    
                </td>"
      end
      table << "<td align='left'>
                  <div style='color: red;' id= \"last_year\">0</div>
                </td>"           
      table << "<td align='left'>
          <div style='color:red;' id = \"last_common-year\">0</div>    
      </td>"
    end        
    table
  end
  
  def sum_last_account_code(size)
    table = ""
    0.upto(size - 2) do |s|
      1.upto(12) do |x|
        table << "<script>                  
                  var x =  $('sum-#{x}-#{s}').innerHTML;
                 // alert (x);
                  if (#{size} != 3){ // jika account code pendapatan dan laba di luar usaha
                    $('sum-last-#{x}').innerHTML = parseFloat($('sum-last-#{x}').innerHTML) - parseFloat(x);
                  }else{
                    $('sum-last-#{x}').innerHTML = parseFloat($('sum-last-#{x}').innerHTML) + parseFloat(x);
                  }                   
                </script>"
      end
      table << "<script>
       // plus untuk commont di sum last account
       if (#{size} != 3){
          $('last_common-year').innerHTML = parseFloat($('last_common-year').innerHTML) - parseFloat($('common-year-#{s}').innerHTML.split('%'));
          $('last_common-year').innerHTML =  $('last_common-year').innerHTML + '%'
          $('last_year').innerHTML = parseFloat($('last_year').innerHTML) - parseFloat($('common-year-#{s}').innerHTML);
       }else{
          $('last_common-year').innerHTML = parseFloat($('last_common-year').innerHTML) +  parseFloat($('common-year-#{s}').innerHTML.split('%'));
          $('last_common-year').innerHTML =  $('last_common-year').innerHTML + '%'
          $('last_year').innerHTML = parseFloat($('last_year').innerHTML) + parseFloat($('common-year-#{s}').innerHTML);
       }
        
       </script>"            
    end
    table
  end
    
  def sum_next_account_code(account,year,depth)
    table = ""           
    $TOTAL_YEARS = 0    
    1.upto(12) do |x|
      sum = 0
      #sum = prepare_get_value_sales("Sales Revenue", year,x, account, "sales")
      sum = prepare_get_value_sales_evaluations("Sales Revenue", year,x, account, "sales")
      # $TOTAL_EXPENSES = $TOTAL_EXPENSES + sum
        
      #display_income_statement_sales(account,year, x)
      table << "<td style='width:100px; text-align:right;'>"
      table << "#{sum}</td>"
      table << "<script>
             var x = parseFloat($('sum-#{x}-#{depth}').innerHTML) + #{sum};
             $('sum-#{x}-#{depth}').innerHTML = x; 
             
             // if ($('sum-last-#{x}') == null) {$('sum-last-#{x}').innerHTML = 0 ;}
             // $('sum-last-#{x}').innerHTML += parseFloat(x); 
              </script>"            
      $TOTAL_YEARS += sum
    end        
    table
  end

  #  def display_income_statement_sales(account,year, month)        
  ##    account_sales    = AccountingAccount.find_by_code(account_code)
  #    val = prepare_get_value_sales("Sales Revenue", year,month, account_sales, "sales")
  #    $TOTAL_EXPENSES = $TOTAL_EXPENSES + val
  #    val
  #  end
    
  #def prepare_get_value_sales(header,year,month, account, type)
  def prepare_get_value_sales_evaluations(header,year,month, account, type)
    first_saldo = {}
    first_saldo = 
      TrialBalance.find(:first,:conditions => ["MONTH(transaction_date) = #{month} AND YEAR(transaction_date) = #{year} and account_id = ?",account.id]
    )    
    result = 0
    aje = []
    result = first_saldo.nil? ? 0 : first_saldo.last_saldo #get_first_saldo(account,year,month)
    aje = get_summary_aje(account, year,month)
    if account.account_type == "debet"
      result = result - aje[1] + aje[0]
    else
      result = result - aje[0] + aje[1]
    end    
    aje = []
    result
  end
       
  def get_first_saldo(group, year, month)
    res = 0
    first_saldo = {}
    # first_saldo = group.trial_balances.find(
    first_saldo = TrialBalance.find(:first,:conditions => ["MONTH(transaction_date) = #{month} AND YEAR(transaction_date) = #{year} and account_id = ?",group.id]
    )    
    res = first_saldo.nil? ? 0 : first_saldo.last_saldo        
    first_saldo = {}
    res
  end

  def get_summary_aje(account, year,month)
    ajs_balances = {}
    accounting_fixed_asset_detail = {}
    aje_debet = 0
    aje_credit = 0
    accounting_fixed_asset_detail = AccountingFixedAssetDetail.find(:first, :conditions => ["MONTH(transaction_date) = '#{month}' AND YEAR(transaction_date) = '#{year}' AND account_id =? ", account.id])
    unless accounting_fixed_asset_detail.nil?
      if accounting_fixed_asset_detail.accounting_fixed_asset.adjustment_account.debit_credit == false
        aje_debet = 0
        aje_credit = accounting_fixed_asset_detail.aje_values
      else
        aje_debet = accounting_fixed_asset_detail.aje_values
        aje_credit = 0
      end
    end
    accounting_fixed_asset_detail = {}
    ajs_balances = AccountingAdjustmentBalance.find(:first, :conditions => ["MONTH(adjustment_date) = '#{:month}' AND YEAR(adjustment_date) = '#{year}' AND account_id =? ", account.id])
    if !ajs_balances.nil? && account.account_type == "debet"
      aje_debet += ajs_balances.values
      aje_credit += ajs_balances.values unless ajs_balances.contra_account_id.nil?
    elsif !ajs_balances.nil?
      aje_credit += ajs_balances.values
      aje_debet += ajs_balances.values unless ajs_balances.contra_account_id.nil?
    end
    ajs_balances = {}    
    return aje_debet, aje_credit
  end

  ###---------------------------- helper for export excell dan pdf -------------------####
  #===================================================================================####
 
  def generate_table_evaluations_report(account, depth)
    output = []
    costs = {}
    $row = 0 
    sum = 0
    table = ""    
    if account.code_a.to_s != '4'
      costs = AccountingAccount.find(:all, :conditions => ["code_a = ? and code_b = ?",account.code_a, account.code_b])
    else
      costs = AccountingAccount.find(:all, :conditions => ["code_a = ?" ,account.code_a])
    end    
    $row = costs.size
    costs.each_with_index do |cost, i|
      if i != 0
        table << "<tr class=#{cycle("grid_3","grid_2")}>"
        $TOTAL_COMMONTH = 0
        table << "<td>&nbsp;</td>"
        if cost.code_d.to_s == "0" && cost.code_e.to_s == "0"
          table << "<td align='left' style='font-weight:bold;'>#{cost.code}</td>"
          table << "<td align='left' style='font-weight:bold;'>#{cost.description}</td>"
        else
          table << "<td align='right'>&nbsp;#{cost.code}</td>"
          table << "<td align='right'>#{cost.description}</td>"
        end
        1.upto(12) do |month|          
          sum = sum_next_account_code_report(cost,$year,month)                       
          $TOTAL_COMMONTH += sum
          table << "<td style='text-align:right;'>#{sum.to_f}</td>"
          output[month] = output[month].nil? ?  0 : output[month]          
          output[month] = output[month].to_f + sum.to_f 
        end
        table << "<td style='text-align:right;'>#{$TOTAL_COMMONTH}</td>"
        table << "<td style='text-align:center;'>#{percentage($TOTAL_COMMONTH, $DIVIDEN)}</td>"
        table << "</tr>"
      end    
    end
    return output, table
  end
 
  def percentage(up, bottom)
    result = "0%"
    if bottom !=0
      result = ((up/ bottom) * 100).to_s+"%"
    end
    result
  end
    
  def sum_first_account_report(account, year, depth)    
    result = 0
    value = []
    tmp = generate_table_evaluations_report(account, depth)    
    value = tmp[0]
    total = 0
    table = ""
    1.upto(12) do |x|      
      table << "<td align='right' style='color:red;'>#{value[x]}</td>"
      total += value[x].to_f
      if x == 12 && depth == 0
        $DIVIDEN = $DIVIDEN + total
      end
    end
    table << "<td style='color:red; text-align:right;'>#{total}</td>"
    ############## PEMBAGIAN COMMON
    if $DIVIDEN !=0
      result = (total / $DIVIDEN).to_s + "%" 
    else
      result = '0%'
    end    
    table << "<td style='color:red; text-align:center;'>#{result}</td>"
    table << tmp[1] 
    table << sum_last_transaction(depth, total, value)
    table
  end 
  
  def sum_last_transaction(depth, total, value)
    ############## SUM LAST TRANSACTION
    table = ""
    if depth == 4      
      table << "<tr class='grid_2'>"
      table << "<td style='color:red;'>#{depth + 2}</td>"
      table << "<td style='color:red;'>81100</td>"
      table << "<td style='color:red;'>Laba dan Rugi</td>"
    end
    $SUM_LAST_COMMONT = $SUM_LAST_COMMONT + total if depth == 3
    $SUM_LAST_COMMONT = $SUM_LAST_COMMONT - total if depth != 3    
    1.upto(12) do |x|       
      if depth == 3
        $SUM_LAST_TRANSACTION = $SUM_LAST_TRANSACTION + value[x].to_f
       
      else
        $SUM_LAST_TRANSACTION = $SUM_LAST_TRANSACTION - value[x].to_f
        
      end                
      table << "<td style='color:red; text-align:right;'>#{$SUM_LAST_TRANSACTION}</td>" if depth == 4
      $SUM_LAST_TRANSACTION = 0 if depth == 4
    end
    ## last common
    table << "<td style='color:red; text-align:right;'>#{$SUM_LAST_COMMONT.to_f}</td>"  if depth == 4
    table << "<td style='color:red; text-align:center;'>#{percentage($SUM_LAST_COMMONT.to_f,$DIVIDEN)}</td>"  if depth == 4
    ###############################    
    table << "</tr>" if depth == 4  
    table
  end
  
  def sum_next_account_code_report(account,year,month)
    value = 0         
    #value = prepare_get_value_sales("Sales Revenue", year,month, account, "sales")                                  
    value = prepare_get_value_sales_evaluations("Sales Revenue", year,month, account, "sales")                                  
    value
  end
  

  def year_value_accounts(account_id, date_year)
    total=  0
    first_saldo = ReportOfYear.find(:first,:conditions => ["YEAR(date_report) = #{date_year} AND account_id = '#{account_id}'"])
    total = first_saldo.nil? ? 0 : first_saldo.value
    $total_account.has_key?(account_id.to_s) == true ? $total_account[account_id.to_s] += total : $total_account = { account_id.to_s => total}
    return format_currency(total)
  end
 
end
