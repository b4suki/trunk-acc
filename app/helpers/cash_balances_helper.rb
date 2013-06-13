module CashBalancesHelper

  def saldo_row(report = false)
    date = params[:date] ? Time.mktime($year, $month, 1, 0, 0, 0, 0) : Time.now
    previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}
    account = AccountingAccount.find(:first, :conditions => ["id=2"])
    @one_month_ago_cash_balance = account.trial_balances.find(
      :first,
      :conditions => ["MONTH(transaction_date) = #{previous_date[:month]} AND YEAR(transaction_date) = #{previous_date[:year]}"]
    )
    @one_month_ago_cash_balance = @one_month_ago_cash_balance.nil? ? 0 : @one_month_ago_cash_balance.last_saldo
    row =  "<tr class='grid_3'>"
    row += "  <td colspan='2'>&nbsp;</td><td><b>Saldo</b></td><td colspan='2'>&nbsp;</td>"
    row += "  <td align='right'>#{format_currency(@one_month_ago_cash_balance)}</td>"
    row += "  <td colspan='2'>&nbsp;</td>" unless report
    row += "</tr>"
    row
  end

  def saldo_row_report
    date = params[:date] ? Time.mktime($year, $month, 1, 0, 0, 0, 0) : Time.now
    previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}
    account = AccountingAccount.find(:first, :conditions => ["id=2"])
    @one_month_ago_cash_balance = account.trial_balances.find(
      :first,
      :conditions => ["MONTH(transaction_date) = #{previous_date[:month]} AND YEAR(transaction_date) = #{previous_date[:year]}"]
    )
    @one_month_ago_cash_balance = @one_month_ago_cash_balance.nil? ? 0 : @one_month_ago_cash_balance.last_saldo
    row =  "<tr class='grid_3'>"
    row += "  <td>&nbsp;</td><td><b>Saldo</b></td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>"
    row += "  <td align='right'>#{format_currency(@one_month_ago_cash_balance)}</td>"
    row += "</tr>"
    row
  end

  def options_for_transaction_type
    options = AccountingTransactionType.find(:all).collect {|p| [ p.name, p.id ] }
    options.unshift(["- Pilih -",""])
  end

  def options_for_payment_procedure
    options = PaymentProcedure.find(:all).collect {|p| [ p.name, p.id ] }
    options.unshift(["- Pilih -",""])
  end

  def subtotal_row_excel
    @one_month_ago_cash_balance = AccountingCashBalance.accumulate_one_month_ago_cash_balance($month, $year)
    row =  "<tr class='grid_2'>"
    row += "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>"
    AccountingTransactionType.find(:all).each do |y|
      AccountingCashBalance.with_dynamic_time($month, $year) do
        @amount = AccountingCashBalance.sum("transaction_value", :conditions => ["transaction_type_id = ?", y.id])
        if y.id == 1
          @amount = @one_month_ago_cash_balance + @amount
        end
      end
      row += "<td align='right'><b>#{format_currency(@amount)}</b></td>"
    end
    row += "  <td>&nbsp;</td>"
    row += "</tr>"
    row
  end

  def subtotal_row_report
    @one_month_ago_cash_balance = AccountingCashBalance.accumulate_one_month_ago_cash_balance($month, $year)
    row =  "<tr class='grid_2'>"
    row += "<td colspan='5'>&nbsp;</td>"
    AccountingTransactionType.find(:all).each do |y|
      AccountingCashBalance.with_dynamic_time($month, $year) do
        @amount = AccountingCashBalance.sum("transaction_value", :conditions => ["transaction_type_id = ?", y.id])
        if y.id == 1
          @amount = @one_month_ago_cash_balance + @amount
        end
      end
      row += "<td align='right'><b>#{format_currency(@amount)}</b></td>"
    end
    row += "</tr>"
    row
  end

  def empty_data_row(report = false)
    row =  "<tr class='grid_2'>"
    row += "  <td class='grid_2' colspan='#{report ? "6" : "8"}' align='center'>Tidak Ada Data</td>"
    row += "</tr>"
    row
  end

  def dynamic_group_header_builder
    row = ""
    AccountingTransactionType.find(:all).each do |transaction_type|
      if !transaction_type.group.nil? && @group != transaction_type.group
        @count_group = AccountingTransactionType.find_all_by_group(transaction_type.group).size
        row += "<th>#{transaction_type.group}</th>"
      elsif transaction_type.group.nil?
        row += "<th>#{transaction_type.name}</th>"
      end
      @group = transaction_type.group
    end
    row
  end

  def dynamic_group_header_builder_report
    row = ""
    AccountingTransactionType.find(:all).each do |transaction_type|
      if !transaction_type.group.nil? && @group != transaction_type.group
        @count_group = AccountingTransactionType.find_all_by_group(transaction_type.group).size
        row += "<th colspan='#{@count_group}' align='center'>#{transaction_type.group}</th>"
      elsif transaction_type.group.nil?
        row += "<th rowspan='2'>#{transaction_type.name}</th>"
      end
      @group = transaction_type.group
    end
    row
  end

  def dynamic_header_builder
    row = ""
    AccountingTransactionType.find(:all).each do |transaction_type|
      row += "<th>#{transaction_type.name}</th>"
    end
    row
  end

  def dynamic_header_builder_report
    row = ""
    AccountingTransactionType.find(:all, :conditions => ["accounting_transaction_types.group IS NOT NULL"]).each do |transaction_type|
      row += "<th>#{transaction_type.name}</th>"
    end
    row
  end

  def dynamic_content_builder(cash_balance)
    row = ""
    unless cash_balance.accounting_transaction_type.nil?
      1.upto(cash_balance.accounting_transaction_type.order - 1) do |x|
        row += "<td>&nbsp;</td>"
      end
      row += "<td align='right'>#{format_currency(cash_balance.transaction_value)}</td>"
      (cash_balance.accounting_transaction_type.order + 1).upto(AccountingTransactionType.find(:all).size) do |y|
        row += "<td>&nbsp;</td>"
      end
    end
    row
  end

  def default_filter_month
    $month.to_i
  end

  def default_filter_year
    $year.to_i
  end

  def selected_account(cash_balance)
    cash_balance.nil? || cash_balance.accounting_account.nil? ? "" : "#{cash_balance.accounting_account.code}   #{cash_balance.accounting_account.description}"
  end

  def selected_contra_account(cash_balance)
    cash_balance.nil? || cash_balance.contra_account.nil? ? "" : "#{cash_balance.contra_account.code}   #{cash_balance.contra_account.description}"
  end

  def selected_cas_type(cash_balance)
    if cash_balance.bkk
      "bkk"
    elsif cash_balance.bkm
      "bkm"
    end
  end

  def initial_data
    AccountingCashBalance.find(:all)
  end

  def selected_cash_account(cash_balance)
    if cash_balance.nil? || cash_balance.accounting_account.nil?
      return ""
    else
      if !cash_balance.bkm.nil?
        "#{cash_balance.contra_account.code}   #{cash_balance.contra_account.description}"
      else
        "#{cash_balance.accounting_account.code}   #{cash_balance.accounting_account.description}"
      end
    end
  end

  def selected_cash_account_id(cash_balance)
    if cash_balance.nil? || cash_balance.accounting_account.nil?
      ""
    else
      if !cash_balance.bkm.nil?
        cash_balance.contra_account.id
      else
        cash_balance.accounting_account.id
      end
    end
  end
  
  private

  def handle_with_zero(object, field)
    object.nil? ? 0 : object.send(field)
  end

  def last_month_saldo
    last_two_month_transaction = AccountingCashBalance.find(:first, :conditions => ["MONTH(created_at) = ?", $month.to_i - 2])
    last_two_month_transaction = !last_two_month_transaction.nil? ? last_two_month_transaction.cash_balance : 0

    last_month_transaction = AccountingCashBalance.find(:first, :conditions => ["MONTH(created_at) = ?", $month.to_i - 1])
    !last_month_transaction.nil? ? (last_month_transaction.cash_balance + last_two_month_transaction) : 0
  end

  def previous_current_month(date)
    date.beginning_of_month.months_ago(1)
  end
end
