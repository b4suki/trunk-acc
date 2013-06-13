module TrialBalancesHelper
  def get_parent_code(parent)
    parent = AccountingAccount.find(parent)
    parent ? parent.code_a : ""
  end

  def display_account_on_trial_balance(groups, result, previous_date, report )
    level = 0
    $SUMMARY_PREVIOUS = 0
    $SUMMARY_DEBET    = 0
    $SUMMARY_CREDIT   = 0
    $SUMMARY_SALDO    = 0
    ret = ''
    ret = "<table width='1000px' class='main_table' cellpadding='0' cellspacing='0'>" unless report
    for group in groups      
        params_id = group.trial_balances.find_by_account_id(group.id)
      if group.parent_id.nil?
      
        first_saldo = get_as_adjusted_saldo(group, previous_date)
        summary          = prepare_show_summary(result, group, false, false)
        classification = group.accounting_account_classification.name
        if classification == "Harta" || classification == "Beban"
          last_saldo       = first_saldo + summary[1]- summary[0]
        elsif classification == "Utang" || classification == "Modal" || classification == "Pendapatan"
          last_saldo       = first_saldo + summary[0]- summary[1]
        end
        $SUMMARY_PREVIOUS += first_saldo
        $SUMMARY_DEBET += summary[1]
        $SUMMARY_CREDIT += summary[0]
        $SUMMARY_SALDO += last_saldo
        ret << "<tr class=#{cycle("grid_2","grid_3")} id='account_#{group.id}'>"
        ret << "<td style='width:20px;' align='center'>#{group.code_a}</td>"
        ret << "<td style='width:20px;' align='center'>#{group.code_b}</td>"
        ret << "<td style='width:20px;' align='center'>#{group.code_c}</td>"
        ret << "<td style='width:20px;' align='center'>#{group.code_d}</td>"
        ret << "<td style='width:20px;' align='center'>#{group.code_e}</td>"
        ret << "<td style='width:400px;'>#{group.description}</td>"
        #        ret << "<td style='width:125px;' align='right'>#{format_currency(first_saldo)}</td>"
        ret << "<td style='width:125px;' align='right'>#{!params_id.nil? ? link_to_remote_redbox(format_currency(first_saldo), {:url => "/accounting/trial_balances/edit/#{params_id.id}"}) : format_currency(first_saldo) }</td>"
        ret << "<td style='width:125px;' align='right'>#{format_currency(summary[1])}</td>"
        ret << "<td style='width:125px;' align='right'>#{format_currency(summary[0])}</td>"
        ret << "<td style='width:125px;' align='right'>#{format_currency(last_saldo)rescue nil }</td>"
        ret << "</tr>"
        ret << find_all_sub_account_on_trial_balance(result,previous_date, group, level, report)
      end
    end
    ret << "</table>" unless report
    return ret
  end

  def find_all_sub_account_on_trial_balance(result,previous_date, group, level, report)
    level += 1
    ret = ""
    group.children.each do |sugroup|
     params_id = sugroup.trial_balances.find_by_account_id(sugroup.id)
      
      first_saldo = get_as_adjusted_saldo(sugroup, previous_date)
      summary = prepare_show_summary(result, sugroup,false, false)
      classification = group.accounting_account_classification.name
      if classification == "Harta" || classification == "Beban"
        last_saldo       = first_saldo + summary[1]- summary[0]
      elsif classification == "Utang" || classification == "Modal" || classification == "Pendapatan"
        last_saldo       = first_saldo + summary[0]- summary[1]
      end
      $SUMMARY_PREVIOUS += first_saldo
      $SUMMARY_DEBET += summary[1]
      $SUMMARY_CREDIT += summary[0]
      $SUMMARY_SALDO += last_saldo
      ret << "<tr class=#{cycle("grid_2","grid_3")} id='account_#{sugroup.id}'>"
      ret << "<td align='center'>#{sugroup.code_a}</td>"
      ret << "<td align='center'>#{sugroup.code_b}</td>"
      ret << "<td align='center'>#{sugroup.code_c}</td>"
      ret << "<td align='center'>#{sugroup.code_d}</td>"
      ret << "<td align='center'>#{sugroup.code_e}</td>"
      ret << "<td>#{sugroup.description}</td>"
#      ret << "<td style='width: 125px;' align='right'>#{format_currency(first_saldo)}</td>"
      ret << "<td style='width: 125px;' align='right'>#{!params_id.nil? ? link_to_remote_redbox(format_currency(first_saldo), {:url => "/accounting/trial_balances/edit/#{params_id.id}"}): format_currency(first_saldo)}</td>"
      ret << "<td style='width: 125px;' align='right'>#{format_currency(summary[1])}</td>"
      ret << "<td style='width: 125px;' align='right'>#{format_currency(summary[0])}</td>"
      ret << "<td style='width: 125px;' align='right'>#{format_currency(last_saldo)}</td>"
      ret << "</tr>"
      ret << find_all_sub_account_on_trial_balance(result,previous_date,sugroup, level, report)
    end
    ret
  end
  
  def display_account_on_trial_balance_pdf(groups, result, previous_result, report = false)
    level = 0
    $SUMMARY_PREVIOUS = 0
    $SUMMARY_DEBET    = 0
    $SUMMARY_CREDIT   = 0
    $SUMMARY_SALDO    = 0
    ret = ""
    for group in groups
      if group.parent_id.nil?
        first_saldo = get_first_saldo_new(group, previous_result[:month],previous_result[:year])
        summary          = prepare_show_summary(result, group, false, false)
        first_saldo      = previous_summary[1]-previous_summary[0]
        last_saldo       = first_saldo+(summary[1]-summary[0])
        $SUMMARY_PREVIOUS += first_saldo
        $SUMMARY_DEBET    += summary[1]
        $SUMMARY_CREDIT   += summary[0]
        $SUMMARY_SALDO    += last_saldo
        ret << "<tr class=#{cycle("grid_2","grid_3")} id=\"account_#{group.id}\">"
        ret << "<td width='10px' style=\"text-align:center;border-left:1px solid #000;\"> #{group.code_a}</td>"
        ret << "<td width='10px' style=\"text-align:center;\"> #{group.code_b}</td>"
        ret << "<td width='10px' style=\"text-align:center;\"> #{group.code_c}</td>"
        ret << "<td width='10px' style=\"text-align:center;\"> #{group.code_d}</td>"
        ret << "<td width='10px' style=\"text-align:center;border-right:1px solid #000;\"> #{group.code_e}</td>"
        ret << "<td width=''> &nbsp;#{group.description}</td>"
        ret << "<td width='' style='text-align:right;'> &nbsp;#{format_currency(first_saldo)}</td>"
        ret << "<td width='' style='text-align:right;'> &nbsp;#{format_currency(summary[1])}</td>"
        ret << "<td width='' style='text-align:right;'> &nbsp;#{format_currency(summary[0])}</td>"
        ret << "<td width='' style='text-align:right;'> #{format_currency(last_saldo)}&nbsp;&nbsp;&nbsp;&nbsp;</td>"
        ret << "</tr>"
        ret << find_all_sub_account_on_trial_balance(result,previous_result, group, level, report)
      end
    end
    ret << "<tr class=\"grid_footer\">"
    ret << "<th width=\"100px\" style=\"text-align:right;\"  colspan=\"6\">Jumlah</th>"
    ret << "<th width=\"125px\" style=\"text-align:right;\" >#{format_currency($SUMMARY_PREVIOUS)}</th>"
    ret << "<th width=\"125px\" style=\"text-align:right;\" >#{format_currency($SUMMARY_DEBET)}</th>"
    ret << "<th width=\"125px\" style=\"text-align:right;\" >#{format_currency($SUMMARY_CREDIT)}</th>"
    ret << "<th width=\"125px\" style=\"text-align:right;\" >#{format_currency($SUMMARY_SALDO)}</th>"
    ret << "</tr>"
  end

  def find_all_sub_account_on_trial_balance_pdf(result,previous_result, group, level, report)
    level += 1
    ret = ""
    #ret << "<tr id=\"new_group_#{group.id}\"></tr>"
    group.children.each do |sugroup|
      first_saldo = get_first_saldo_new(sugroup, previous_result[:month], previous_result[:year])
      summary = prepare_show_summary(result, sugroup,false, false)
      first_saldo = previous_summary[1]-previous_summary[0]
      last_saldo = first_saldo+(summary[1]-summary[0])
      $SUMMARY_PREVIOUS += first_saldo
      $SUMMARY_DEBET    += summary[1]
      $SUMMARY_CREDIT   += summary[0]
      $SUMMARY_SALDO    += last_saldo
      ret << "<tr class=#{cycle("grid_2","grid_3")} id=\"account_#{sugroup.id}\">"
      ret << "<td style=\"text-align:centerborder='1px';border-right:none;\"> #{sugroup.code_a}</td>"
      ret << "<td style=\"text-align:center;\"> #{sugroup.code_b}</td>"
      ret << "<td style=\"text-align:center;\"> #{sugroup.code_c}</td>"
      ret << "<td style=\"text-align:center;\"> #{sugroup.code_d}</td>"
      ret << "<td style=\"text-align:center;\"> #{sugroup.code_e}</td>"
      ret << "<td><div style=\"width:#{level*25}px;height:20px;float:left;\"></div>#{sugroup.description}</td>" unless report
      ret << "<td width='' style='text-align:right;'> &nbsp;#{format_currency(first_saldo)}</td>"
      ret << "<td width='' style='text-align:right;'> &nbsp;#{format_currency(summary[1])}</td>"
      ret << "<td width='' style='text-align:right;'> &nbsp;#{format_currency(summary[0])}</td>"
      ret << "<td width='' style='text-align:right;'> &nbsp;#{format_currency(last_saldo)}&nbsp;&nbsp;&nbsp;&nbsp;</td>"
      ret << "</tr>"
      ret << find_all_sub_account_on_trial_balance_pdf(result,previous_result,sugroup, level, report)
    end
    ret
  end
  
  
  def create_space(level)
    a = ""
    0.upto(level) do |i|
      a += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
    end
    a
  end

  def prepare_show_summary(result, account, debit, credit)
    account = {:select => false, :value => account.id}
    summary_debet = 0    
    summary_credit = 0
    result.each do |journal|
      summary = summary_general_journal_from_cash_balance(journal, account, debit, credit)
      summary_credit += summary[0]
      summary_debet  += summary[1]
      summary = summary_general_journal_from_bank_balance(journal, account, debit, credit)
      summary_credit += summary[0]
      summary_debet  += summary[1]
      summary = summary_general_journal_from_sale_balance(journal, account, debit, credit)
      summary_credit += summary[0]
      summary_debet  += summary[1]
      summary = summary_general_journal_from_purchase_balance(journal, account, debit, credit)
      summary_credit += summary[0]
      summary_debet  += summary[1]
      summary = summary_general_journal_from_manual_journal(journal, account, debit, credit)
      summary_credit += summary[0]
      summary_debet  += summary[1]
    end
    return summary_credit, summary_debet
  end

  def summary_general_journal_from_cash_balance(journal, account, debit, credit)
    ret_debet = 0
    ret_kredit = 0
    if journal.class == AccountingCashBalance
      if (journal.account_id == account[:value].to_i)
        ret_debet += journal.transaction_value
      elsif journal.contra_account_id == account[:value].to_i
        ret_kredit += journal.transaction_value
      end
    end
    return  ret_kredit, ret_debet
  end

  def summary_general_journal_from_bank_balance(journal, account, debit, credit)
    ret_debet = 0
    ret_kredit = 0
    if journal.class == AccountingBankBalance
      if(journal.account_id == account[:value].to_i)
        ret_debet += journal.transaction_value
      elsif journal.contra_account_id == account[:value].to_i
        ret_kredit += journal.transaction_value
      end
    end
    return ret_kredit, ret_debet
  end

  def summary_general_journal_from_sale_balance(journal, account, debit, credit)
    ret_debet = 0
    ret_kredit = 0
    if journal.class == AccountingSaleBalance
      journal.values.each do |value|
        if value.account_id == account[:value].to_i
          if value.is_debit
            ret_debet += value.value
          else
            ret_kredit += value.value
          end
        end
      end
    end
    return ret_kredit, ret_debet
  end
  
  def summary_general_journal_from_purchase_balance(journal, account, debit, credit)
    ret_debet = 0
    ret_kredit = 0    
    if journal.class == AccountingPurchaseBalance    
      journal.values.each do |value|
        if value.account_id == account[:value].to_i
          if value.is_debit
            ret_debet += value.value
          else
            ret_kredit += value.value
          end
        end
      end
    end    
    return ret_kredit, ret_debet
  end
 
  def summary_general_journal_from_manual_journal(journal, account, debit, credit)
    ret_debet = 0
    ret_kredit = 0
    if journal.class == AccountingManualJournal
      journal.values.each do |value|
        if value.account_id == account[:value].to_i
          if value.is_debit
            ret_debet += value.value
          else
            ret_kredit += value.value
          end
        end
      end
    end
    return ret_kredit, ret_debet
  end
 
  
  
  def get_first_saldo(group, options ={})      
    first_saldo = group.trial_balances.find(
      :first, 
      :conditions => ["MONTH(transaction_date) = #{options[:month]} AND YEAR(transaction_date) = #{options[:year]}"]
    )
    first_saldo = first_saldo.nil? ? 0 : first_saldo.last_saldo   
  end
  
  def get_first_saldo_new(group, options1, options2)    
    first_saldo = group.trial_balances.find(
      :first, 
      :conditions => ["MONTH(transaction_date) = #{options1} AND YEAR(transaction_date) = #{options2}"]
    )
    first_saldo = first_saldo.nil? ? 0 : first_saldo.last_saldo   
  end

  def display_account_on_trial_balance_pdf(groups, result, previous_date, report = false)
    level = 0
    $SUMMARY_PREVIOUS = 0
    $SUMMARY_DEBET    = 0
    $SUMMARY_CREDIT   = 0
    $SUMMARY_SALDO    = 0
    ret = "<table  width='700px;' border='1'; cellpadding='0' cellspacing='0'>"
    for group in groups
      if group.parent_id.nil?
        first_saldo = get_first_saldo_new(group, previous_date[:month], previous_date[:year])
        summary          = prepare_show_summary(result, group, false, false)
        last_saldo       = first_saldo+(summary[1]-summary[0])
        $SUMMARY_PREVIOUS += first_saldo
        $SUMMARY_DEBET    += summary[1]
        $SUMMARY_CREDIT   += summary[0]
        $SUMMARY_SALDO    += last_saldo
        #        ret << "<tr class=#{cycle("grid_2","grid_3")} id=\"account_#{group.id}\">"
        ret << "<td width='20px' align='center'> #{group.code_a}</td>"
        ret << "<td width='20px' align='center'> #{group.code_b}</td>"
        ret << "<td width='20px' align='center'> #{group.code_c}</td>"
        ret << "<td width='20px' align='center'> #{group.code_d}</td>"
        ret << "<td width='20px' align='center'> #{group.code_e}</td>"
        ret << "<td width='200px'> &nbsp;#{group.description}</td>"
        ret << "<td width='100px' align='right'> &nbsp;#{format_currency(first_saldo)}</td>"
        ret << "<td width='100px' align='right'> &nbsp;#{format_currency(summary[1])}</td>"
        ret << "<td width='100px' align='right'> &nbsp;#{format_currency(summary[0])}</td>"
        ret << "<td width='100px' align='right'> #{format_currency(last_saldo)}&nbsp;&nbsp;&nbsp;&nbsp;</td>"
        ret << "</tr>"
        ret << find_all_sub_account_on_trial_balance_pdf(result,previous_date, group, level, report)
      end
    end
    ret << "</table>"
  end
  
  def find_all_sub_account_on_trial_balance_pdf(result,previous_date, group, level, report)
    level += 1
    ret = ""
    #ret << "<tr id=\"new_group_#{group.id}\"></tr>"
    group.children.each do |sugroup|
      first_saldo = get_first_saldo_new(sugroup, previous_date[:month],previous_date[:year])
      summary = prepare_show_summary(result, sugroup,false, false)
      last_saldo = first_saldo+(summary[1]-summary[0])
      $SUMMARY_PREVIOUS += first_saldo
      $SUMMARY_DEBET    += summary[1]
      $SUMMARY_CREDIT   += summary[0]
      $SUMMARY_SALDO    += last_saldo
      ret << "<tr class=#{cycle("grid_2","grid_3")} id=\"account_#{sugroup.id}\">"
      ret << "<td align='center'> #{sugroup.code_a}</td>"
      ret << "<td align='center'> #{sugroup.code_b}</td>"
      ret << "<td align='center'> #{sugroup.code_c}</td>"
      ret << "<td align='center'> #{sugroup.code_d}</td>"
      ret << "<td align='center'> #{sugroup.code_e}</td>"
      ret << "<td><div style=\"width:#{level*25}px;height:20px;float:left;\"></div>#{sugroup.description}</td>" unless report
      ret << "<td width='125px' align='right'> &nbsp;#{format_currency(first_saldo)}</td>"
      ret << "<td width='125px' align='right'> &nbsp;#{format_currency(summary[1])}</td>"
      ret << "<td width='125px' align='right'> &nbsp;#{format_currency(summary[0])}</td>"
      ret << "<td width='125px' align='right'> &nbsp;#{format_currency(last_saldo)}&nbsp;&nbsp;&nbsp;&nbsp;</td>"
      ret << "</tr>"
      ret << find_all_sub_account_on_trial_balance_pdf(result,previous_date,sugroup, level, report)
    end
    ret
  end

  def display_account_on_initial_saldo(groups)
    ret = "<table width='600px' class='main_table' cellpadding='0' cellspacing='0'>"
    ret << "<tr>"
    ret << "<th colspan='5'>Kode Rekening</th>"
    ret << "<th>Keterangan</th>"
    ret << "<th>Saldo Awal</th>"
    ret << "</tr>"
    x = 0
    for group in groups
      x += 1
      ret << "<tr class=#{cycle("grid_2","grid_3")} id='account_#{group.id}'>"
      ret << "<td style='width:10px;' align='center'>#{group.code_a}</td>"
      ret << "<td style='width:10px;' align='center'>#{group.code_b}</td>"
      ret << "<td style='width:10px;' align='center'>#{group.code_c}</td>"
      ret << "<td style='width:10px;' align='center'>#{group.code_d}</td>"
      ret << "<td style='width:10px;' align='center'>#{group.code_e}</td>"
      ret << "<td style='width:200px;'>#{group.description}</td>"
      ret << "<td style='width:50px;' align='right'>#{hidden_field_tag "account_id_#{x}", group.id}#{text_field_tag "saldo_#{x}", 0, :style => "text-align: right;"}</td>"
      ret << "</tr>"
    end
    ret << "</table>"
    ret << "<script type='text/javascript'>"
    1.upto(x) do |i|  
      ret << "var val_saldo_#{i} = new LiveValidation('saldo_#{x}');
        val_saldo_#{i}.add(Validate.Numericality);"
    end if x > 0
    ret << "</script>"
    ret << hidden_field_tag("account_count", x)
  end

end
