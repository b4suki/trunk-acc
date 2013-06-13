module Accounting::DollarBalancesHelper

  def dollar_balance_initial_data
    AccountingDollarBalance.find(:all)
  end

  def dollar_balance_saldo_row
    row = ""
    row << "<tr class='grid_2'>"
    row <<  "<td colspan='4' align='center'><b>Saldo</b></td>"
    row <<  "<td align='right'><b>" + format_currency(AccountingDollarBalance.accumulate_one_month_ago_dollar_balance($month, $year)) + "</b></td>"
    row <<  "<td colspan='3'>&nbsp;</td>"
    row << "</tr>"
    return row
  end
end
