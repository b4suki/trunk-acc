module IncomeStatementHelper
  def display_income_statement_revenues(date)
    income_accounts   = AccountingAccountClassification.find_by_name("Pendapatan").accounting_accounts
    $TOTAL_SALES = 0
    $TOTAL_BRUTO = 0
    ret = ""
    income_accounts.each do |account|
      if account.account_type != 'debet'
        prepare_get_value_sales(account.description, date, account, ret, "sales", nil )
      end
    end
    ret << "<tr class='grid_2'>"
    ret << "<td colspan='2'>PENDAPTAN BRUTO DARI OPRASIONAL</td>"
    ret << "<td width='100' style='text-align:right; border-top:1px solid #000'></td>"
    ret << "<td width='100' style='text-align:right;'>#{format_currency $TOTAL_BRUTO}</td>"
    ret << "</tr>"
    income_accounts.each do |account|
      if account.account_type == 'debet'
        prepare_get_value_sales(account.description, date, account, ret, "sales", true)
      end
    end
    template_html_total("TOTAL OF REVENUES", ret, format_currency($TOTAL_SALES))
    $TOTAL = $TOTAL_SALES
    ret
  end

  def display_income_statement_cost_good_of_sold(date)
    ret = ""
    $TOTAL_COST_OFF_GOOD = 0
    direct_material_accounts    = AccountingAccount.find(:all, :conditions => ["code IN (51101, 51102,51103)"]) #AccountingAccount.find(:all, :conditions => ["code IN (52100,52101,52102, 52103)"])
    indirect_material_accounts    = AccountingAccount.find(:all, :conditions => ["code IN (51301,51302,51303,51304,51305)"])
    prepare_get_value_cost_good("Direct Material", date, direct_material_accounts, ret, "cost")
    prepare_get_value_cost_good("In Direct Material", date, indirect_material_accounts, ret, "cost")

    show_discount_cost_of_gold(date, ret)
    template_html_total("TOTAL OF COST OF GOOD SOLD", ret,format_currency($TOTAL_COST_OFF_GOOD))
    return ret
  end

  def get_account_children(account, tmp_account)
    account.children.each do |account_child|
      tmp_account << account_child
      tmp_account << get_account_children(account_child, tmp_account)
    end
    return tmp_account.compact
  end

  def display_expenses(date)
    ret = ""
    $TOTAL_EXPENSES = 0
    expense_accounts   = AccountingAccountClassification.find_by_name("Beban").accounting_accounts

    expense_accounts.each do |account|
      if account.id != 117 && account.id != 118 && account.id != 67 && account.id != 60
        prepare_get_value_expenses(account.description, date, [account], ret, "expenses")
      end
    end
    template_html_total("TOTAL EXPENSES", ret, format_currency($TOTAL_EXPENSES))
    return ret
  end

  def display_revenue(date)
    ret = ""
    $TOTAL_REVENUE = 0
    bank_interest_accounts = AccountingAccount.find(:all, :conditions => ["code IN (61100)"])
    other_accounts = AccountingAccount.find(:all, :conditions => ["code IN (61200, 61300, 61400)"])
    interest_accounts = AccountingAccount.find(:all, :conditions => ["code IN (62100)"])
    other_interest_accounts = AccountingAccount.find(:all, :conditions => ["code IN (62200,62300, 62400)"])
    prepare_get_value_revenue("Bank Interest", date, bank_interest_accounts, ret, "revenue")
    prepare_get_value_revenue("Others Revenue", date, other_accounts, ret, "revenue")
    prepare_get_value_revenue("Interest Expense", date, interest_accounts, ret, "revenue")
    prepare_get_value_revenue("Others Interest Expense", date, other_interest_accounts, ret, "revenue")
    return ret
  end

  def prepare_get_value_revenue(header, date, accounts, ret, type)
    total = 0
    accounts.each do |account|
      #total += get_first_saldo(account, date)
      #result = get_first_saldo(account, date)
      result = get_first_saldo_income(account,date)
      #aje = get_summary_aje(account, date)
      aje = get_summary_aje_income(account, date)
      if account.account_type == "debet"
        result = result - aje[1] + aje[0]
      else
        result = result - aje[0] + aje[1]
      end
      total += result

    end

    template_html_content(header, ret, format_currency(total), type)
    $TOTAL_REVENUE += total
    return ret
  end

  def prepare_get_value_cost_good(header, date, accounts, ret, type)
    total = 0
    accounts.each do |account|
      #total += get_first_saldo(account, date)
      #result = get_first_saldo(account, date)
      result = get_first_saldo_income(account, date)
      #aje = get_summary_aje(account, date)
      aje = get_summary_aje_income(account, date)
      if account.account_type == "debet"
        result = result - aje[1] + aje[0]
      else
        result = result - aje[0] + aje[1]
      end
      total += result

    end

    template_html_content(header, ret, format_currency(total), type)
    $TOTAL_COST_OFF_GOOD += total
    return ret
  end

  def prepare_get_value_expenses(header, date, accounts, ret, type)
    total = 0
    accounts.each do |account|
      #result = get_first_saldo(account, date)
      result = get_first_saldo_income(account, date)
      #aje = get_summary_aje(account, date)
      aje = get_summary_aje_income(account, date)
      result = result - aje[1] + aje[0]

      result = get_as_adjusted_saldo(account, date)
      total += result
    end

    template_html_content(header, ret, format_currency(total), type,nil)
    $TOTAL_EXPENSES += total
    return ret
  end

  def prepare_get_value_sales(header, date, account, ret, type, type_debet)
    #result = get_first_saldo(account, date)
    result = get_first_saldo_income(account, date)
    #aje = get_summary_aje(account, date)
    aje = get_summary_aje_income(account, date)
    result = result - aje[0] + aje[1]
    result = get_as_adjusted_saldo(account, date)
    $TOTAL_SALES += result
    $TOTAL_BRUTO += result if type_debet != true
    template_html_content(header, ret, format_currency(result), type, type_debet)
    return ret
  end

  def template_html_content(header, ret, result, type, type_debet)
    ret << "<tr class='grid_2'>"
    ret << "<td>&nbsp;</td>"
    ret << "<td>#{header}</td>"
    if type == "sales"
      ret << "<td width='100' style='text-align:right;'>#{result if type_debet != true}</td>"
      ret << "<td width='100' style='text-align:right;'>#{result if type_debet == true}</td>"
    else
      ret << "<td width='100' style='text-align:right;'>#{result}</td>"
      ret << "<td width='100'></td>"
    end
    ret << "</tr>"
    ret
  end

  def template_html_total(header, ret, total)
    ret << "<tr class='grid_3'>"
    ret << "<td colspan='3'>#{header}</td>"
    ret << "<td style='text-align:right; border-top:1px solid #000'>#{total}</td>"
    ret << "</tr>"
    ret
  end

  def show_discount_cost_of_gold(date, ret)
    accounts    = AccountingAccount.find(:all, :conditions => ["code IN (51201,51202)"])
    #result_discount = get_first_saldo(accounts[0], date)
    #result_retur = get_first_saldo(accounts[1], date)
    result_discount = get_first_saldo_income(accounts[0], date)
    result_retur = get_first_saldo_income(accounts[1], date)

    ret << "<tr class='grid_2'>"
    ret << "<td>&nbsp;</td>"
    ret << " <td>#{create_space(1)}Discount</td>"
    ret << " <td style='text-align:right;'>#{format_currency(result_discount-result_retur)}</td>"
    ret << " <td></td>"
    ret << "</tr>"
    $TOTAL_COST_OFF_GOOD += result_discount-result_retur
    return ret
  end


  def get_first_saldo_income(group, previous_date)
    first_saldo = group.trial_balances.find(
      :first,
      :conditions => ["MONTH(transaction_date) = #{previous_date[:month]} AND YEAR(transaction_date) = #{previous_date[:year]}"]
    )
    first_saldo = first_saldo.nil? ? 0 : first_saldo.last_saldo
  end

  def get_summary_aje_income(account, date)
    aje_debet = 0
    aje_credit = 0
    accounting_fixed_asset_detail = AccountingFixedAssetDetail.find(:first, :conditions => ["MONTH(transaction_date) = '#{date[:month]}' AND YEAR(transaction_date) = '#{date[:year]}' AND account_id =? ", account.id])
    unless accounting_fixed_asset_detail.nil?
      if accounting_fixed_asset_detail.accounting_fixed_asset.adjustment_account.debit_credit == false
        aje_debet = 0
        aje_credit = accounting_fixed_asset_detail.aje_values
      else
        aje_debet = accounting_fixed_asset_detail.aje_values
        aje_credit = 0
      end
    end
    ajs_balances = AccountingAdjustmentBalance.find(:first, :conditions => ["MONTH(adjustment_date) = '#{date[:month]}' AND YEAR(adjustment_date) = '#{date[:year]}' AND account_id =? ", account.id])
    if !ajs_balances.nil? && account.account_type == "debet"
      aje_debet += ajs_balances.values
      aje_credit += ajs_balances.values unless ajs_balances.contra_account_id.nil?
    elsif !ajs_balances.nil?
      aje_credit += ajs_balances.values
      aje_debet += ajs_balances.values unless ajs_balances.contra_account_id.nil?
    end
    return aje_debet, aje_credit
  end

  def display_hpp_purchase(date)
    ret = ""
    $TOTAL_HPP = 0
    $TOTAL_PURCHASE = 0
    expense_accounts = AccountingAccountClassification.find_by_name("Beban").accounting_accounts

    expense_accounts.each do |account|
      if (account.id.to_s == "117" || account.id.to_s == "118"|| account.id.to_s == "67")
        prepare_get_value_hpp_purchase(account.description, date, [account], ret, "expenses")
      end
    end
    frist_and_last_stock(date, ret)
    $TOTAL_SALES = $TOTAL_HPP > 0 ? $TOTAL_SALES - $TOTAL_HPP :  $TOTAL_SALES + $TOTAL_HPP
    template_html_total("LABA BRUTO", ret, format_currency($TOTAL_SALES))

    return ret
  end

  def frist_and_last_stock(date, ret)
    date_previous = Time.mktime(date[:year],date[:month], 1, 0, 0, 0, 0)
    previous_date = {:month => previous_current_month(date_previous).strftime("%m"), :year => previous_current_month(date_previous).strftime("%Y")}
    stock_first = TrialBalance.find(:first,:conditions => ["MONTH(transaction_date) = #{previous_date[:month]} AND YEAR(transaction_date) = #{previous_date[:year]} AND account_id = 12"])
    stock_last = TrialBalance.find(:first,:conditions => ["MONTH(transaction_date) = #{date[:month]} AND YEAR(transaction_date) = #{date[:year]} AND account_id = 12"])
    history_item = ItemHistory.find(:all, :conditions => ["MONTH(last_date) = #{previous_date[:month]} AND YEAR(last_date) = #{previous_date[:year]}"]).sum(&:value)
    stock_first = !stock_first.nil? ? stock_first.as_adjusted : history_item 
    stock_last = !stock_last.nil? ? stock_last.as_adjusted : 0
    
    $TOTAL_HPP = ( stock_first - stock_last)
    ret << "<tr class='grid_3'>"
    ret << "<td></td><td>Persedian Awal Barang Dagang</td>"
    ret << "<td style='text-align:right; '>#{format_currency stock_first }</td><td></td>"
    ret << "</tr>"
    ret << "<tr class='grid_3'>"
    ret << "<td></td><td >Persedian Akhir Barang Dagang</td>"
    ret << "<td style='text-align:right;'>#{format_currency stock_last}</td><td></td>"
    ret << "</tr>"
    ret << "<tr class='grid_3'>"
    ret << "<td colspan='2' >TOTAL HPP</td>"
    ret << "<td style='text-align:right; border-top:1px solid #000'>#{format_currency $TOTAL_HPP}</td><td></td>"
    ret << "</tr>"
  end

  def prepare_get_value_hpp_purchase(header, date, accounts, ret, type)
    total = 0
    accounts.each do |account|
      #result = get_first_saldo(account, date)
      result = get_first_saldo_income(account, date)
      #aje = get_summary_aje(account, date)
      aje = get_summary_aje_income(account, date)
      result = result - aje[1] + aje[0]

      result = get_as_adjusted_saldo(account, date)
      total += result
      $TOTAL_PURCHASE += total if (account.id.to_s == "117" || account.id.to_s == "118")
      $TOTAL_PURCHASE -= total if (account.id.to_s == "67" )
    end
    template_html_content(header, ret, format_currency(total), type,nil)
    return ret
  end

end
