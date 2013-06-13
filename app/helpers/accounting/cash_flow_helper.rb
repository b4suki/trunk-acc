module Accounting::CashFlowHelper
  def display_cash_flow(cash_flow_activity, date)
    ret  = "<tr class='grid_1'>"
    ret << "<th colspan='4'><b>Arus Kas dari Aktivitas #{cash_flow_activity.name.capitalize}</b></th>"
    ret << "</tr>"

    total_saldo = 0
    cash_flow_activity.categories.each do |category|
      ret << "<tr class='#{cycle("grid_2", "grid_3")}'>"
      ret << "<td>&nbsp;</td>"
      ret << "<td>#{category.title}</td>"
      account_saldo = 0
      category.accounts.each do |account|
        if category.is_cash_receipt
          account_saldo += get_summary_cash_receipt(account, date)
        else
          account_saldo -= get_summary_cash_expenditure(account, date)
        end
      end
      total_saldo += account_saldo
      ret << "<td align='right' #{"style='color: red'" if !category.is_cash_receipt}>#{format_currency(account_saldo)}</td>"
      ret << "<td>&nbsp;</td>"
      ret << "</tr>"
    end

    ret << "<tr class='grid_2'>"
    ret << "<th>&nbsp;</th>"
    ret << "<th>Arus kas bersih dari aktivitas #{cash_flow_activity.name.downcase}</th>"
    ret << "<th>&nbsp;</th>"
    ret << "<th align='right'>#{format_currency(total_saldo)}</th>"
    ret << "</tr>"
    return ret, total_saldo
  end

  def get_summary_cash_receipt(account, date)
    summary_saldo = 0
    conditions = []
    conditions << "EXTRACT(MONTH FROM created_at) = #{date[:month]}"
    conditions << "EXTRACT(YEAR FROM created_at) = #{date[:year]}"
    conditions << "contra_account_id='#{account.id}'"
    conditions = conditions.join(" AND ")
    journal = AccountingCashBalance.find(:all, :conditions => conditions)
    journal.collect{|x| summary_saldo += x.transaction_value}
    journal = AccountingBankBalance.find(:all, :conditions => conditions)
    journal.collect{|x| summary_saldo += x.transaction_value}
    summary_saldo
  end

  def get_summary_cash_expenditure(account, date)
    summary_saldo = 0
    conditions = []
    conditions << "EXTRACT(MONTH FROM created_at) = #{date[:month]}"
    conditions << "EXTRACT(YEAR FROM created_at) = #{date[:year]}"
    conditions = conditions.join(" AND ")
    journal = AccountingCashBalance.find(:all, :conditions => conditions + " AND account_id='#{account.id}'")
    journal.collect{|x| summary_saldo += x.transaction_value}
    journal = AccountingBankBalance.find(:all, :conditions => conditions + " AND account_id='#{account.id}'")
    journal.collect{|x| summary_saldo += x.transaction_value}
    summary_saldo
  end
end
