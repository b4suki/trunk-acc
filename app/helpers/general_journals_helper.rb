module GeneralJournalsHelper
  def create_general_journal(result, account)
    ret = ""
    result.each do |journal|
      case journal.class.to_s
      when "AccountingCashBalance"
        ret << create_general_journal_from_cash_balance(journal, account)
      when "AccountingBankBalance"
        ret << create_general_journal_from_bank_balance(journal, account)
      when "AccountingSaleBalance"
        ret << create_general_journal_from_sale_balance(journal, account)
      when "AccountingPurchaseBalance"
        ret << create_general_journal_from_purchase_balance(journal, account)
      when "AccountingManualJournal"
        ret << create_general_journal_from_manual_journal(journal, account)
      end
    end

    return ret
  end

  def create_general_journal_from_cash_balance(journal, account)
    ret = ""
    if (!account[:select] || journal.account_id == account[:value].to_i)
      ret << "<tr class=#{cycle("grid_2","grid_3")}>"
      ret << "<td style='width:180px;' align='center'>#{journal.created_at.strftime("%d-%b-%Y")}</td>"
      ret << "<td style='width:200px;' align='center'>#{journal.evidence}</td>"
      ret << "<td style='width:400px;color:magenta;'>#{journal.accounting_account.description}</td>"
      ret << "<td style='width:180px;' align='center'>#{!journal.job_id.nil? ? journal.job_id : '&nbsp;'}</td>"
      ret << "<td style='width:180px;' align='center'>#{journal.accounting_account.code}</td>"
      ret << "<td style='width:180px;' align='right'>#{format_currency(journal.transaction_value)}</td>"
      ret << "<td style='width:180px;' align='right'>&nbsp;</td>"
      ret << "</tr>"
      $TOTAL_DEBIT += journal.transaction_value
    end
    if (!account[:select] || journal.contra_account_id == account[:value].to_i)
      ret << "<tr class=#{cycle("grid_2","grid_3")}>"
      ret << "<td style='width:180px;' align='center'>&nbsp;</td>"
      ret << "<td style='width:200px;' align='center'>&nbsp;</td>"
      ret << "<td style='width:400px; padding-left:30px;'>#{journal.contra_account.description}</td>"
      ret << "<td style='width:180px;' align='center'>#{!journal.job_id.nil? ? journal.job_id : '&nbsp;'}</td>"
      ret << "<td style='width:180px;' align='center'>#{journal.contra_account.code}</td>"
      ret << "<td style='width:180px;' align='right'>&nbsp;</td>"
      ret << "<td style='width:180px;' align='right'>#{format_currency(journal.transaction_value)}</td>"
      ret << "</tr>"
      $TOTAL_CREDIT += journal.transaction_value
    end
    return ret    
  end
  
  def create_general_journal_from_bank_balance(journal, account)
    ret = ""  
    if(!account[:select] || journal.account_id == account[:value].to_i)
      ret << "<tr class=#{cycle("grid_2","grid_3")}>"
      ret << "<td style='width:180px;' align='center'>#{journal.created_at.strftime("%d-%b-%Y")}</td>"
      ret << "<td style='width:200px;' align='center'>#{journal.evidence}</td>"
      ret << "<td style='width:400px;color: green;'>#{journal.accounting_account.description rescue nil}</td>"
      ret << "<td style='width:180px;' align='center'>#{!journal.job_id.nil? ? journal.job_id : '&nbsp;'}</td>"
      ret << "<td style='width:180px;' align='center'>#{journal.accounting_account.code rescue nil}</td>"
      ret << "<td style='width:180px;' align='right'>#{format_currency(journal.transaction_value)}</td>"
      ret << "<td style='width:180px;' align='right'>&nbsp;</td>"
      ret << "</tr>"
      $TOTAL_DEBIT += journal.transaction_value
    end
    #      if (!account[:select] || journal.accounting_account.id == account[:value].to_i)
    if (!account[:select] || journal.contra_account_id == account[:value].to_i)
      ret << "<tr class=#{cycle("grid_2","grid_3")}>"
      ret << "<td style='width:180px;' align='center'>&nbsp;</td>"
      ret << "<td style='width:200px;' align='center'>&nbsp;</td>"
      ret << "<td style='width:400px; padding-left:30px;'>#{journal.contra_account.description rescue nil}</td>"
      ret << "<td style='width:180px;text-align:center;'>#{journal.job_id}</td>"
      ret << "<td style='width:180px;' align='center'>#{journal.contra_account.code rescue nil}</td>"
      ret << "<td style='width:180px;' align='right'>&nbsp;</td>"
      ret << "<td style='width:180px;' align='right'>#{format_currency(journal.transaction_value)}</td>"
      ret << "</tr>"
      $TOTAL_CREDIT += journal.transaction_value
    end
    return ret    
  end
  
  def create_general_journal_from_sale_balance(journal, account)
    ret = ""
    journal.values.each_with_index do |jurnal, count|
      ret << "<tr class=#{cycle("grid_2","grid_3")}>"
      ret << "<td style=\"width:180px;\" align='center'>#{ count == 0 ? journal.created_at.strftime("%d-%b-%Y") : '&nbsp;'}</td>"
      ret << "<td style=\"width:200px;\" align='center'>#{count == 0 ? journal.evidence  : '&nbsp;' }</td>"
      padding = jurnal.is_debit ? "" : "padding-left:30px;"
      ret << "<td style=\"width:400px;#{padding}color:#{'blue' if count == 0};\">
                    #{jurnal.account.description}
                    </td>"
      ret << "<td style=\"width:180px;\" align='center'>#{count==0 ? journal.job_id : "&nbsp;"}</td>"
      ret << "<td style=\"width:180px;\" align='center'>#{jurnal.account.code}</td>"
      if jurnal.is_debit
        ret << "<td style=\"width:180px;\" align='right'>#{format_currency(jurnal.value)}</td>"
        ret << "<td style=\"width:180px;\" align='right'>&nbsp;</td>"
        $TOTAL_DEBIT += jurnal.value
      else
        ret << "<td style=\"width:180px;\" align='right'>&nbsp;</td>"
        ret << "<td style=\"width:180px;\" align='right'>#{format_currency(jurnal.value)}</td>"
        $TOTAL_CREDIT += jurnal.value
      end
      ret << "</tr>"
    end
    return ret    
  end

  def create_general_journal_from_purchase_balance(journal, account)
    ret = ""
    journal.values.each_with_index do |jurnal, count|
      ret << "<tr class=#{cycle("grid_2","grid_3")}>"
      ret << "<td style=\"width:180px;\" align='center'>#{ count == 0 ? journal.created_at.strftime("%d-%b-%Y") : '&nbsp;'}</td>"
      ret << "<td style=\"width:200px;\" align='center'>#{count == 0 ? journal.evidence  : '&nbsp;' }</td>"
      padding = jurnal.is_debit ? "" : "padding-left:30px;"
      ret << "<td style=\"width:400px;#{padding}color:#{'red' if count == 0};\">
                    #{jurnal.account.description}
                    </td>"
      ret << "<td style=\"width:180px;\" align='center'>#{count==0 ? journal.job_id : "&nbsp;"}</td>"
      ret << "<td style=\"width:180px;\" align='center'>#{jurnal.account.code}</td>"
      if jurnal.is_debit
        ret << "<td style=\"width:180px;\" align='right'>#{format_currency(jurnal.value)}</td>"
        ret << "<td style=\"width:180px;\" align='right'>&nbsp;</td>"
        $TOTAL_DEBIT += jurnal.value
      else
        ret << "<td style=\"width:180px;\" align='right'>&nbsp;</td>"
        ret << "<td style=\"width:180px;\" align='right'>#{format_currency(jurnal.value)}</td>"
        $TOTAL_CREDIT += jurnal.value
      end
      ret << "</tr>"
    end
    return ret
  end
    
     
  def filter_account_purchase(purchases, account ={})
    ret = []
    purchases.values.each_with_index do |purchase, count|
      if purchase.account_id == account[:value].to_i
        ret << "<tr class=#{cycle("grid_2","grid_3")}>"
        ret << "<td style=\"width:180px;text-align:center;\">#{purchases.invoice_date.strftime("%d-%b-%Y") }</td>"
        ret << "<td style=\"width:200px;text-align:center;\">#{purchases.evidence.nil? ? "" : purchases.evidence }</td>"
        color = ''
        ret << "<td style=\"width:400px;color:#{color = 'red' if purchases.account_id == account[:value].to_i};\">
                  #{                      
        if purchases.account_id == account[:value].to_i# || purchases.contra_account_id == account[:value].to_i
        purchases.description.nil? ? "" : purchases.description.upcase
        else
        purchase.account.description
        end
                  }</td>"
        ret << "<td style=\"width:180px;text-align:center;\">#{purchases.job_id}</td>"
        ret << "<td style=\"width:180px;text-align:center;\">#{purchase.account.code}</td>"
        if purchase.is_debit
          ret << "<td style=\"width:180px;text-align:right;\">#{format_currency(purchase.value)}</td>"
          ret << "<td style=\"width:180px;text-align:right;\"></td>"
          $TOTAL_DEBIT += purchase.value
        else
          ret << "<td style=\"width:180px;text-align:right;\"></td>"
          ret << "<td style=\"width:180px;text-align:center;\">#{format_currency(purchase.value)}</td>"
          $TOTAL_CREDIT += purchase.value
        end
        ret << "</tr>"
      end
    end
    return ret
  end

  def create_general_journal_from_manual_journal(journal, account)
    ret = ""
    journal.values.each_with_index do |value, count|
      if (!account[:select] || value.account_id == account[:value].to_i)
        if value.is_debit
          ret << "<tr class=#{cycle("grid_2","grid_3")}>"
          ret << "<td style='width:180px;' align='center'>#{count == 0 ? journal.created_at.strftime("%d-%b-%Y") : '&nbsp'}</td>"
           ret << "<td style=\"width:200px;\" align='center'>#{!journal.evidence.nil? ? journal.evidence  : '&nbsp;' }</td>"
          ret << "<td style=\"width:400px;color:#{'maroon' if count == 0};\">#{value.account.description}</td>"
          ret << "<td style='width:180px;' align='center'>#{!value.journal.job_id.nil? ? value.journal.job_id : '&nbsp;'}</td>"
#          ret << "<td style='width:180px;' align='center'>#{value.journal.job_id}</td>"
          ret << "<td style='width:180px;' align='center'>#{value.account.code}</td>"
          ret << "<td style='width:180px;' align='right'>#{format_currency(value.value)}</td>"
          ret << "<td style='width:180px;' align='right'>&nbsp;</td>"
          ret << "</tr>"
          $TOTAL_DEBIT += value.value
        elsif !value.is_debit
          ret << "<tr class=#{cycle("grid_2","grid_3")}>"
          ret << "<td style='width:180px;' align='center'>&nbsp;</td>"
          ret << "<td style='width:200px;' align='center'>&nbsp;</td>"
          ret << "<td style='width:400px; padding-left:30px;'>#{value.account.description}</td>"
          ret << "<td style='width:180px;' align='center'>#{value.journal.job_id}</td>"
          ret << "<td style='width:180px;' align='center'>#{value.account.code}</td>"
          ret << "<td style='width:180px;' align='right'>&nbsp;</td>"
          ret << "<td style='width:180px;' align='right'>#{format_currency(value.value)}</td>"
          ret << "</tr>"
          $TOTAL_CREDIT += value.value
        end
      end
    end
    return ret
  end
  
  def option_select_date_filter(result)
    tmp = result.collect{|x| x.created_at.strftime("%d-%b-%Y") }.uniq
    tmp.collect{|x| [x, x]}.unshift(["(All)", "all"]).sort
  end
  
  def option_select_evidence_filter(result)
    tmp = result.collect{|x| x.evidence.blank? ? nil : x.evidence }.uniq
    if tmp.include?(nil)
      tmp = tmp.compact
      tmp.collect{|x| [x, x]}.unshift(["(All)", "all"]).push(["blank", "blank"]).push(["non blank", "non blank"]).sort
    else
      tmp.collect{|x| [x, x]}.unshift(["(All)", "all"]).sort
    end
  end
  
  def option_select_description_filter(result)
    class_sale = result.select {|item| item.class == AccountingSaleBalance}
    tmp = result.collect{|x| x.description.blank? ? nil : x.description }.uniq
    tmp << find_description_sale(class_sale) if class_sale
    if tmp.include?(nil)
      tmp = tmp.flatten
      tmp = tmp.compact
      tmp = tmp.uniq
      tmp.collect{|x| [x, x]}.unshift(["(All)", "all"]).push(["blank", "blank"]).push(["non blank", "non blank"]).sort
    else
      tmp = tmp.flatten
      tmp = tmp.compact
      tmp = tmp.uniq
      tmp.collect{|x| [x, x]}.unshift(["(All)", "all"]).sort
    end
  end
  
  def find_description_sale(class_sale)
    tmp = []
    class_sale.each do |sale|
      tmp << sale.accounting_sale_balance_details.collect{|x| x.product_name}
    end
    tmp = tmp.uniq
    tmp = tmp.compact
    tmp = tmp.flatten
    return tmp
  end
  
  def option_select_job_filter(result)
    tmp = result.collect{|x| x.job_id}.uniq
    if tmp.include?(nil)
      tmp = tmp.compact
      tmp.collect{|x| [x, x]}.unshift(["(All)", "all"]).push(["blank", "blank"]).push(["non blank", "non blank"])
    else
      tmp.collect{|x| [x, x]}.unshift(["(All)", "all"])
    end
  end
  
  def option_select_account_filter(result)
    class_sale = result.select {|item| item.class == AccountingSaleBalance}
    class_purchase = result.select {|item| item.class == AccountingPurchaseBalance}
    if $SELECTED_ACCOUNT == "all"
      tmp = find_account_sale_purchase(class_sale, class_purchase)
      tmp << result.collect{|x| x.account_id.blank? ? nil : x.account_id }.uniq
      tmp = tmp.flatten
      tmp2 = result.collect{|x| x.contra_account_id.blank? || x.contra_account_id == 0  ? nil : x.contra_account_id }.uniq
    else
      tmp = find_account_sale_purchase(class_sale, class_purchase)
      tmp  << result.collect{|x| x.account_id if x.account_id == $SELECTED_ACCOUNT.to_i }.uniq
      tmp = tmp.flatten
      tmp2 = result.collect{|x| x.contra_account_id if x.contra_account_id == $SELECTED_ACCOUNT.to_i }.uniq
    end
    tmp = tmp + tmp2
    tmp = tmp.uniq
    if tmp.include?(nil)
      tmp = tmp.compact
      tmp = tmp.sort
      tmp.collect{|x| [AccountingAccount.find(x).code, x]}.unshift(["(All)", "all"]).push(["blank", "blank"]).push(["non blank", "non blank"])
    else
      tmp = tmp.compact
      tmp = tmp.sort
      tmp.collect{|x| [AccountingAccount.find(x).code, x]}.unshift(["(All)", "all"])
    end
  end
      
  def find_account_sale_purchase(class_sale, class_purchase)
    tmp = []
    class_sale.each do |sale|
      tmp  << sale.values.collect{|x| x.account_id}
    end
    class_purchase.each do |purchase|
      tmp << purchase.values.collect{|x| x.account_id}
    end
    tmp = tmp.uniq
    tmp = tmp.compact
    tmp = tmp.flatten
    return tmp
  end
  
  def option_select_account_filter_new(results)
    tmp1, tmp2 = ""
    tmp_cash = []
    tmp_bank = []
    tmp_account_purchase =[]
    tmp_account_sale = []
    tmp = results.collect do |result|
      if $SELECTED_ACCOUNT == "all"
        if result.class == AccountingSaleBalance
          result.values.each_with_index do |value, i|
            tmp_account_purchase[i] = value.account.code
          end
          tmp_account_purchase
        elsif result.class == AccountingPurchaseBalance
          result.values.each_with_index do |value, i|
            tmp_account_sale[i] = value.account.code
          end
          tmp_account_sale
        elsif result.class == AccountingBankBalance
          tmp1 = result.accounting_account.nil? ? nil:result.accounting_account.code
          tmp2 = result.contra_account_id.nil? ? nil : AccountingAccount.find_by_id(result.contra_account_id).code
          tmp_bank = [tmp1, tmp2]
        elsif result.class == AccountingCashBalance
          tmp1 = result.accounting_account.nil? ? nil : result.accounting_account.code
          tmp2 = result.contra_account_id.nil? ? nil : AccountingAccount.find_by_id(result.contra_account_id).code
          tmp_cash = [tmp1, tmp2]
        end
      else
        
      end
    end
    tmp = tmp.flatten
    tmp = tmp.uniq
    tmp = tmp.compact
    tmp = tmp.sort
    tmp.collect{|x| [x, AccountingAccount.find_by_code(x).id]}.unshift(["(All)", "all"])
  end
  
  def option_select_debit_filter(result)
    tmp = result.collect do |x|
      if x.class == AccountingCashBalance
        x.transaction_type_id == 1 || (x.transaction_type_id != 1 && x.contra_account) ?  x.transaction_value : nil
      elsif x.class == AccountingBankBalance
        x.debit ? x.transaction_value : nil
      elsif x.class == AccountingPurchaseBalance
        x.values.collect{|val| val.value if val.is_debit}
      elsif x.class == AccountingSaleBalance
        x.values.collect{|val| val.value if val.is_debit}
      end
    end
    tmp = tmp.flatten
    tmp = tmp.uniq
    tmp = tmp.compact
    tmp = tmp.sort
    tmp.collect{|x| [x, x]}.unshift(["(All)", "all"])
  end
  
  def option_select_credit_filter(result)
    tmp = result.collect do |x|
      if x.class == AccountingCashBalance
        x.transaction_type_id != 1 || (x.transaction_type_id == 1 && x.contra_account) ?  x.transaction_value : nil
      elsif x.class == AccountingBankBalance
        x.credit ? x.transaction_value : nil
      elsif x.class == AccountingPurchaseBalance
        x.values.collect{|val| val.value unless val.is_debit}
      elsif x.class == AccountingSaleBalance
        x.values.collect{|val| val.value unless val.is_debit}
      end
    end
    tmp = tmp.flatten
    tmp = tmp.uniq
    tmp = tmp.compact
    tmp = tmp.sort
    tmp.collect{|x| [x, x]}.unshift(["(All)", "all"])
  end
  
  def show_total_bottom
     
  end
end
