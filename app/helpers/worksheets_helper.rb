module WorksheetsHelper
  def display_account_on_worksheet(groups, previous_date, report = false)
    level = 0
    
    ret = ""
    ret = "<table  width='1300px;' class='main_table' cellpadding='0' cellspacing='0'>" unless report
    for group in groups
      if group.parent_id.nil?
        first_saldo = get_first_saldo_worksheet(group, previous_date)
        worksheet = prepare_worksheet_balance(group, first_saldo, previous_date)
        
        ret << "<tr class=#{cycle("grid_2","grid_3")} id=\"account_#{group.id}\">"
        ret << "<td width='20px' align='center'> #{group.code_a}</td>"
        ret << "<td width='20px' align='center'> #{group.code_b}</td>"
        ret << "<td width='20px' align='center'> #{group.code_c}</td>"
        ret << "<td width='20px' align='center'> #{group.code_d}</td>"
        ret << "<td width='20px' align='center'> #{group.code_e}</td>"
        ret << "<td width='400px'>#{group.description}</td>"
        #trial balance
        ret << "<td width='100px' align='right'>#{worksheet[0]}</td>"
        ret << "<td width='100px' align='right'>#{worksheet[1]}</td>"
        #AJE
        ret << "<td width='100px' align='right'>#{worksheet[2]}</td>"
        ret << "<td width='100px' align='right'>#{worksheet[3]}</td>"
        #As Adjusted
        ret << "<td width='100px' align='right'>#{worksheet[4]}</td>"
        ret << "<td width='100px' align='right'>#{worksheet[5]}</td>"
        #Income Statement
        ret << "<td width='100px' align='right'>#{worksheet[6]}</td>"
        ret << "<td width='100px' align='right'>#{worksheet[7]}</td>"
        #Balance Sheet
        ret << "<td width='100px' align='right'>#{worksheet[8]}</td>"
        ret << "<td width='100px' align='right'> #{worksheet[9]}</td>"
        ret << "</tr>"
        ret << find_all_sub_account_on_worksheet(previous_date, group, level, report)
      end
    end
    ret << "</table>" unless report
    ret
  end

  def find_all_sub_account_on_worksheet(previous_date, group, level, report)
    level += 1
    ret = ""
    group.children.each do |sugroup|
      first_saldo = get_first_saldo_worksheet(sugroup, previous_date)
      worksheet = prepare_worksheet_balance(sugroup, first_saldo, previous_date)
      ret << "<tr class=#{cycle('grid_2','grid_3')} id=\"account_#{sugroup.id}\">"
      ret << "<td align='center'>#{sugroup.code_a}</td>"
      ret << "<td align='center'> #{sugroup.code_b}</td>"
      ret << "<td align='center'> #{sugroup.code_c}</td>"
      ret << "<td align='center'> #{sugroup.code_d}</td>"
      ret << "<td align='center'> #{sugroup.code_e}</td>"
      ret << "<td>#{sugroup.description}</td>" #unless report
      ret << "<td align='right'>#{worksheet[0]}</td>"
      ret << "<td align='right'>#{worksheet[1]}</td>"
      ret << "<td align='right'>#{worksheet[2]}</td>"
      ret << "<td align='right'>#{worksheet[3]}</td>"
      ret << "<td align='right'>#{worksheet[4]}</td>"
      ret << "<td align='right'>#{worksheet[5]}</td>"
      ret << "<td align='right'>#{worksheet[6]}</td>"
      ret << "<td align='right'>#{worksheet[7]}</td>"
      ret << "<td align='right'>#{worksheet[8]}</td>"
      ret << "<td align='right'>#{worksheet[9]}</td>"
      ret << "</tr>"
      ret << find_all_sub_account_on_worksheet(previous_date,sugroup, level, report)
    end
    ret
  end
  
  def get_first_saldo_worksheet(group, previous_date)
    first_saldo = group.trial_balances.find(
      :first, 
      :conditions => ["MONTH(transaction_date) = #{previous_date[:month]} AND YEAR(transaction_date) = #{previous_date[:year]}"]
    )
    first_saldo = first_saldo.nil? ? 0 : first_saldo.last_saldo
  end
  
  def prepare_worksheet_balance(account, trial_balance, previous_date)    
    aje = get_summary_worksheet_aje(account, previous_date)
	  aje_debet  = aje[0] 
    aje_credit = aje[1]
    as_adjusted_saldo = get_as_adjusted_saldo(account, previous_date)
    if account.accounting_account_classification.is_debit
      if trial_balance < 0
        trial_balance_debet  = 0
        trial_balance_credit = trial_balance.abs
      else
        trial_balance_debet  = trial_balance
        trial_balance_credit = 0
      end

      as_adjusted_value = (trial_balance_debet - trial_balance_credit + aje_debet - aje_credit)

      if as_adjusted_value < 0
        as_adjusted_debet = "&nbsp;"
        as_adjusted_credit = as_adjusted_value.abs
      else
        as_adjusted_debet = as_adjusted_value
        as_adjusted_credit = "&nbsp;"
      end

      income_statement_debet = "&nbsp;"
      income_statement_credit = "&nbsp;"
      balance_sheet_debet = "&nbsp;"
      balance_sheet_credit = "&nbsp;"

      trial_balance < 0 ? trial_balance_debet = "&nbsp;" : trial_balance_credit = "&nbsp;"
    else
      trial_balance_credit = trial_balance

      as_adjusted_value = (trial_balance_credit + aje_credit - aje_debet)

      if as_adjusted_value < 0
        as_adjusted_debet  = as_adjusted_value.abs
        as_adjusted_credit = 0
      else
        as_adjusted_debet  = 0
        as_adjusted_credit = as_adjusted_value
      end

      income_statement_debet = "&nbsp;"
      income_statement_credit = "&nbsp;"
      balance_sheet_debet = "&nbsp;"
      balance_sheet_credit = "&nbsp;"

      trial_balance_debet  = "&nbsp;"
    end

    account_classification = account.accounting_account_classification.name
    if account_classification=='Pendapatan' || account_classification=='Beban'
      income_statement_debet = as_adjusted_debet
      income_statement_credit = as_adjusted_credit
    elsif account_classification=='Harta' || account_classification=='Utang' || account_classification=='Modal'
      balance_sheet_debet = as_adjusted_debet
      balance_sheet_credit = as_adjusted_credit
    end
    
    $SUM_TRIAL_BALANCE_DEBET  += trial_balance_debet if trial_balance_debet != "&nbsp;"
    $SUM_TRIAL_BALANCE_CREDIT += trial_balance_credit if trial_balance_credit != "&nbsp;"
    $SUM_AJE_DEBET            += aje_debet if aje_debet != "&nbsp;"
    $SUM_AJE_CREDIT           += aje_credit if aje_credit != "&nbsp;"
    $SUM_AS_ADJUSTED_DEBET    += as_adjusted_debet if as_adjusted_debet != "&nbsp;"
    $SUM_AS_ADJUSTED_CREDIT   += as_adjusted_credit if as_adjusted_credit != "&nbsp;"
    $SUM_INCOME_STATEMENT_DEBET += income_statement_debet if income_statement_debet != "&nbsp;"
    $SUM_INCOME_STATEMENT_CREDIT += income_statement_credit if income_statement_credit != "&nbsp;"
    $SUM_BALANCE_SHEET_DEBET += balance_sheet_debet if balance_sheet_debet != "&nbsp;"
    $SUM_BALANCE_SHEET_CREDIT += balance_sheet_credit if balance_sheet_credit != "&nbsp;"

    trial_balance_debet     = format_currency(trial_balance_debet) if trial_balance_debet != "&nbsp;" 
    trial_balance_credit    = format_currency(trial_balance_credit) if trial_balance_credit != "&nbsp;"
    aje_debet               = format_currency(aje_debet) if aje_debet != "&nbsp;"
    aje_credit              = format_currency(aje_credit) if aje_credit != "&nbsp;"
    as_adjusted_debet       = format_currency(as_adjusted_debet) if as_adjusted_debet != "&nbsp;"
    as_adjusted_credit      = format_currency(as_adjusted_credit) if as_adjusted_credit != "&nbsp;"
    income_statement_debet  = format_currency(income_statement_debet) if income_statement_debet != "&nbsp;"
    income_statement_credit = format_currency(income_statement_credit) if income_statement_credit != "&nbsp;"
    balance_sheet_debet     = format_currency(balance_sheet_debet) if balance_sheet_debet != "&nbsp;"
    balance_sheet_credit    = format_currency(balance_sheet_credit) if balance_sheet_credit != "&nbsp;"
    
    return trial_balance_debet , trial_balance_credit, aje_debet, aje_credit, as_adjusted_debet, as_adjusted_credit, income_statement_debet, income_statement_credit, balance_sheet_debet, balance_sheet_credit
  end
  
  def get_summary_worksheet_aje(account, period)
    aje_debet = 0
    aje_credit = 0

    conditions = []
    conditions << "MONTH(accounting_journals.created_at)='#{period[:month]}'"
    conditions << "YEAR(accounting_journals.created_at)='#{period[:year]}'"
    conditions << "accounting_journal_values.account_id='#{account.id}'"
    conditions = conditions.join(" AND ")

    adjustment_entries = AccountingAdjustment.find(:all, :include => "values", :conditions => conditions)
    adjustment_entries.each do |adjustment_entry|
      adjustment_entry.values.each do |value|
        if value.is_debit
          aje_debet += value.value
        elsif !value.is_debit
          aje_credit += value.value
        end
      end
    end
    return aje_debet, aje_credit
  end
  
  def display_account_on_worksheet_pdf(groups, previous_date, report = false)
    level = 0
    
    ret = ""
    ret = "<table  width='600px;' border='1' cellpadding='0' cellspacing='0'>"
    for group in groups
      if group.parent_id.nil?
        #first_saldo = get_first_saldo(group, previous_date) 
        first_saldo = get_first_saldo_worksheet(group, previous_date) 
        worksheet = prepare_worksheet_balance(group, first_saldo, previous_date)
        
        ret << "<tr class=#{cycle("grid_2","grid_3")} id=\"account_#{group.id}\">"
        ret << "<td width='20px' align='center'> #{group.code_a}</td>"
        ret << "<td width='20px' align='center'> #{group.code_b}</td>"
        ret << "<td width='20px' align='center'> #{group.code_c}</td>"
        ret << "<td width='20px' align='center'> #{group.code_d}</td>"
        ret << "<td width='20px' align='center'> #{group.code_e}</td>"
        ret << "<td width='400px'>{group.description}</td>"
        #trial balance
        ret << "<td width='70px' align='center'>#{worksheet[0]}</td>"
        ret << "<td width='70px' align='center'>#{worksheet[1]}</td>"
        #AJE
        ret << "<td width='70px' align='right'>#{worksheet[2]}</td>"
        ret << "<td width='70px' align='right'>#{worksheet[3]}</td>"
        #As Adjusted
        ret << "<td width='70px' align='right'>#{worksheet[4]}</td>"
        ret << "<td width='70px' align='right'>#{worksheet[5]}</td>"
        #Income Statement
        ret << "<td width='70px' align='right'>#{worksheet[6]}</td>"
        ret << "<td width='70px' align='right'>#{worksheet[7]}</td>"
        #Balance Sheet
        ret << "<td width='70px' align='right'>#{worksheet[8]}</td>"
        ret << "<td width='70px' align='right'> #{worksheet[9]}</td>"        
        ret << "</tr>"
        ret << find_all_sub_account_on_worksheet_pdf(previous_date, group, level, report)
      end
    end
    ret << "</table>"
    ret
  end

  def find_all_sub_account_on_worksheet_pdf(previous_date, group, level, report)
    level += 1
    ret = ""
    group.children.each do |sugroup|
      #first_saldo = get_first_saldo(sugroup, previous_date)
      first_saldo = get_first_saldo_worksheet(sugroup, previous_date)
      worksheet = prepare_worksheet_balance(sugroup, first_saldo, previous_date)
      ret << "<tr class=#{cycle('grid_2','grid_3')} id=\"account_#{sugroup.id}\">"
      ret << "<td align='center'> #{sugroup.code_a}</td>"
      ret << "<td align='center'> #{sugroup.code_b}</td>"
      ret << "<td align='center'> #{sugroup.code_c}</td>"
      ret << "<td align='center'> #{sugroup.code_d}</td>"
      ret << "<td align='center'> #{sugroup.code_e}</td>"
#      ret << "<td><div style=\"width:#{level*25}px;height:20px;float:left;\"></div>#{sugroup.description}</td>" unless report
      ret << "<td>#{sugroup.description}</td>" unless report
      ret << "<td align='right'>#{worksheet[0]}</td>"
      ret << "<td align='right'>#{worksheet[1]}</td>"
      ret << "<td align='right'>#{worksheet[2]}</td>"
      ret << "<td align='right'>#{worksheet[3]}</td>"
      ret << "<td align='right'>#{worksheet[4]}</td>"
      ret << "<td align='right'>#{worksheet[5]}</td>"
      ret << "<td align='right'>#{worksheet[6]}</td>"
      ret << "<td align='right'>#{worksheet[7]}</td>"
      ret << "<td align='right'> #{worksheet[8]}</td>"
      ret << "<td align='right'>#{worksheet[9]}</td>"
      ret << "</tr>"
      ret << find_all_sub_account_on_worksheet_pdf(previous_date,sugroup, level, report)
    end
    ret
  end
end
