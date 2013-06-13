module BankBalancesHelper
  def saldo_bank_row(saldo_bank)
    ret = ''
    date = params[:date] ? Time.mktime($year, $month, 1, 0, 0, 0, 0) : Time.now
    previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}
    accounts_bank =  AccountingSaleDebitCredit.find(:all, :conditions => ["account_type = 'Bank' OR account_type = 'cash' AND debit = '1'"])
    accounts_bank.each  do |account|
      one_month_ago = TrialBalance.find(
        :first,
        :conditions => ["MONTH(transaction_date) = #{previous_date[:month]} AND YEAR(transaction_date) = #{previous_date[:year]} AND account_id = '#{account.account_id}'"]
      )
      one_month_ago = one_month_ago.nil? ? 0 : one_month_ago.last_saldo
      ret << '<div style="float: left;margin: 5px 10px 5px 3px;">'
      ret << '<table width="220" cellspacing="0" cellpadding="0" class="sum_table">'
      ret << '<tr>'
      ret << "<th>Saldo Awal #{account.accounting_account.description}</th>"
      ret << "<td align='right' class='grid_2_sum'> #{format_currency one_month_ago}</td>"
      ret << '</tr>'
      ret << '<tr>'
      ret << "<th>Saldo Akhir #{account.accounting_account.description}</th>"
      ret << "<td align='right' class='grid_2_sum'> #{format_currency saldo_bank[account.accounting_account.description] += one_month_ago }</td>"
      ret << '</tr>'
      ret << '</table>'
      ret << '</div>'
    end
    return ret
  end

  def saldo_bank_row_report(saldo_bank)
    ret = ''
    date = params[:date] ? Time.mktime($year, $month, 1, 0, 0, 0, 0) : Time.now
    previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}
    accounts_bank =  AccountingSaleDebitCredit.find(:all, :conditions => ["account_type = 'Bank' OR account_type = 'cash' AND debit = '1'"])
    accounts_bank.each  do |account|
      one_month_ago = TrialBalance.find(
        :first,
        :conditions => ["MONTH(transaction_date) = #{previous_date[:month]} AND YEAR(transaction_date) = #{previous_date[:year]} AND account_id = '#{account.account_id}'"]
      )
      one_month_ago = one_month_ago.nil? ? 0 : one_month_ago.last_saldo
      ret << '<tr>'
      ret << "<th  align='left'>Saldo Awal #{account.accounting_account.description}</th>"
      ret << "<td align='right' class='grid_2_sum'> #{format_currency one_month_ago}</td>"
      ret << '</tr>'
      ret << '<tr>'
      ret << "<th  align='left'>Saldo Akhir #{account.accounting_account.description}</th>"
      ret << "<td align='right' class='grid_2_sum'> #{format_currency saldo_bank[account.accounting_account.description] += one_month_ago }</td>"
      ret << '</tr>'
    end
    return ret
  end

  def bank_balance_saldo_row(report = false)
    #    date = params[:date] ? Time.mktime($year, $month, 1, 0, 0, 0, 0) : Time.now
    #    previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}
    #    account = AccountingAccount.find(:first, :conditions => ["id=3"])
    #    @one_month_ago_cash_balance = account.trial_balances.find(
    #      :first,
    #      :conditions => ["MONTH(transaction_date) = #{previous_date[:month]} AND YEAR(transaction_date) = #{previous_date[:year]}"]
    #    )
    #    @one_month_ago_cash_balance = @one_month_ago_cash_balance.nil? ? 0 : @one_month_ago_cash_balance.last_saldo
    row = "<tr class='grid_3'>"
    row += "  <td colspan='4'>&nbsp;</td>"
    row += "  <td><b>Saldo</b></td>"
    row += "  <td colspan='2'>&nbsp;</td>" unless report
    row += "  <td align='right'>#{format_currency(@first_saldo)}</td>"
    row += "  <td colspan='3'>&nbsp;</td>"
    row += "</tr>"
    row
  end

  def bank_balance_saldo_row_report(report = false)
    date = params[:date] ? Time.mktime($year, $month, 1, 0, 0, 0, 0) : Time.now
    previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}
    account = AccountingAccount.find(:first, :conditions => ["id=3"])
    @one_month_ago_cash_balance = account.trial_balances.find(
      :first,
      :conditions => ["MONTH(transaction_date) = #{previous_date[:month]} AND YEAR(transaction_date) = #{previous_date[:year]}"]
    )
    @one_month_ago_cash_balance = @one_month_ago_cash_balance.nil? ? 0 : @one_month_ago_cash_balance.last_saldo
    row = "<tr class='grid_3'>"
    row += "  <td colspan='4'>&nbsp;</td>"
    row += "  <td><b>Saldo</b></td>"
    row += "  <td colspan='2'>&nbsp;</td>" unless report
    row += "  <td align='right'>#{format_currency(@one_month_ago_cash_balance)}</td>"
    row += "</tr>"
    row
  end
  
  def default_filter_month
    $month.to_i
  end
  
  def default_filter_year
    $year.to_i
  end
  
  def selected_debit_credit(bank_balance)
    if bank_balance.debit 
      "debit"
    elsif bank_balance.credit
      "credit"
    else
      ""
    end 
  end
  
  def selected_account(bank_balance)
    if bank_balance.nil? || bank_balance.accounting_account.nil?
      return ""
    else
      if bank_balance.debit
        "#{bank_balance.contra_account.code}   #{bank_balance.contra_account.description}"
      else
        "#{bank_balance.accounting_account.code}   #{bank_balance.accounting_account.description}"
      end
    end
  end

  def selected_account_id(bank_balance)
    if bank_balance.nil? || bank_balance.accounting_account.nil?
      ""
    else
      if bank_balance.debit
        bank_balance.contra_account.id
      else
        bank_balance.accounting_account.id
      end
    end
  end
  
  def selected_contra_account(bank_balance)
    bank_balance.nil? || bank_balance.contra_account.nil? ? "" : "#{bank_balance.contra_account.code}   #{bank_balance.contra_account.description}"
  end

  def selected_cash_type(bank_balance)
    if bank_balance.bkk
      "bkk"
    elsif bank_balance.bkm
      "bkm"
    end
  end

  def bank_balance_initial_data
    AccountingBankBalance.find(:all)
  end

  def options_for_bank_cash_type
    options = AccountingBankCash.find(:all).collect {|p| [ p.description, p.account_id ] }
  end

  def selected_bank_cash_type(bank_balance)
    if bank_balance.nil? || bank_balance.accounting_account.nil?
      ""
    else
      if bank_balance.debit
        bank_balance.accounting_account.id
      else
        bank_balance.contra_account.id
      end
    end
  end
  
  private
  
  def handle_with_zero(object, field)
    value = object.nil? ? 0 : object.send(field)
  end
end
