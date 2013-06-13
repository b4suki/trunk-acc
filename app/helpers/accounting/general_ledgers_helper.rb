module Accounting::GeneralLedgersHelper
  def create_general_ledger(journals, account, date)
    saldo = get_as_adjusted_saldo(account, date)
    total_debit = 0
    total_credit = 0
    is_debit = account.accounting_account_classification.is_debit
    ret = "<tr class='grid_3'><td>&nbsp;</td><td colspan='2'>Saldo Awal</td>"
    if is_debit
      ret << "<td align='right'>#{format_currency(saldo)}</td>"
      ret << "<td align='right'>&nbsp;</td>"
    else
      ret << "<td align='right'>&nbsp;</td>"
      ret << "<td align='right'>#{format_currency(saldo)}</td>"
    end
    ret << "<td align='right'>#{format_currency(saldo)}</td>"
    ret << "</tr>"

    journals.each do |journal|
      case journal.class.to_s
      when "AccountingCashBalance"
        if journal.accounting_account == account
          ret << "<tr class=#{cycle("grid_2","grid_3")}>"
          ret << "<td align='center'>#{format_date(journal.created_at)}</td>"
          ret << "<td style='color:magenta;'>#{journal.accounting_account.description}</td>"
          ret << "<td>#{journal.description}</td>"
          ret << "<td align='right'>#{format_currency(journal.transaction_value)}</td>"
          ret << "<td align='right'>&nbsp;</td>"
          saldo = is_debit ? saldo + journal.transaction_value : saldo - journal.transaction_value
          ret << "<td align='right'>#{format_currency(saldo)}</td>"
          ret << "</tr>"
          total_debit += journal.transaction_value
        elsif journal.contra_account == account
          ret << "<tr class=#{cycle("grid_2","grid_3")}>"
          ret << "<td align='center'>#{format_date(journal.created_at)}</td>"
          ret << "<td style='color:magenta;'>#{journal.contra_account.description}</td>"
          ret << "<td>#{journal.description}</td>"
          ret << "<td align='right'>&nbsp;</td>"
          ret << "<td align='right'>#{format_currency(journal.transaction_value)}</td>"
          saldo = is_debit ? saldo - journal.transaction_value : saldo + journal.transaction_value
          ret << "<td align='right'>#{format_currency(saldo)}</td>"
          ret << "</tr>"
          total_credit += journal.transaction_value
        end

      when "AccountingBankBalance"
        if journal.accounting_account == account
          ret << "<tr class=#{cycle("grid_2","grid_3")}>"
          ret << "<td align='center'>#{format_date(journal.created_at)}</td>"
          ret << "<td style='color:green;'>#{journal.accounting_account.description}</td>"
          ret << "<td>#{journal.description}</td>"
          ret << "<td align='right'>#{format_currency(journal.transaction_value)}</td>"
          ret << "<td align='right'>&nbsp;</td>"
          saldo = is_debit ? saldo + journal.transaction_value : saldo - journal.transaction_value
          ret << "<td align='right'>#{format_currency(saldo)}</td>"
          ret << "</tr>"
          total_debit += journal.transaction_value
        elsif journal.contra_account == account
          ret << "<tr class=#{cycle("grid_2","grid_3")}>"
          ret << "<td align='center'>#{format_date(journal.created_at)}</td>"
          ret << "<td style='color:green;'>#{journal.contra_account.description}</td>"
          ret << "<td>#{journal.description}</td>"
          ret << "<td align='right'>&nbsp;</td>"
          ret << "<td align='right'>#{format_currency(journal.transaction_value)}</td>"
          saldo = is_debit ? saldo - journal.transaction_value : saldo + journal.transaction_value
          ret << "<td align='right'>#{format_currency(saldo)}</td>"
          ret << "</tr>"
          total_credit += journal.transaction_value
        end

      when "AccountingSaleBalance"
        journal.values.each do |jurnal|
          if jurnal.account == account
            ret << "<tr class=#{cycle("grid_2","grid_3")}>"
            ret << "<td align='center'>#{format_date(journal.created_at)}</td>"
            ret << "<td style='color:blue'>#{jurnal.account.description}</td>"
            ret << "<td>#{journal.description}</td>"
            if jurnal.is_debit
              ret << "<td align='right'>#{format_currency(jurnal.value)}</td>"
              ret << "<td align='right'>&nbsp;</td>"
              total_debit += jurnal.value
              saldo = is_debit ? saldo + jurnal.value : saldo - jurnal.value
            else
              ret << "<td align='right'>&nbsp;</td>"
              ret << "<td align='right'>#{format_currency(jurnal.value)}</td>"
              total_credit += jurnal.value
              saldo = is_debit ? saldo - jurnal.value : saldo + jurnal.value
            end
            ret << "<td align='right'>#{format_currency(saldo)}</td>"
            ret << "</tr>"
          end
        end

      when "AccountingPurchaseBalance"
        journal.values.each do |jurnal|
          if jurnal.account == account
            ret << "<tr class=#{cycle("grid_2","grid_3")}>"
            ret << "<td align='center'>#{format_date(journal.created_at)}</td>"
            ret << "<td style='color:red'>#{jurnal.account.description}</td>"
            ret << "<td>#{journal.description}</td>"
            if jurnal.is_debit
              ret << "<td align='right'>#{format_currency(jurnal.value)}</td>"
              ret << "<td align='right'>&nbsp;</td>"
              total_debit += jurnal.value
              saldo = is_debit ? saldo + jurnal.value : saldo - jurnal.value
            else
              ret << "<td align='right'>&nbsp;</td>"
              ret << "<td align='right'>#{format_currency(jurnal.value)}</td>"
              total_credit += jurnal.value
              saldo = is_debit ? saldo - jurnal.value : saldo + jurnal.value
            end
            ret << "<td align='right'>#{format_currency(saldo)}</td>"
            ret << "</tr>"
          end
        end

      when "AccountingManualJournal"
        journal.values.each do |value|
          if value.account == account
            if value.is_debit
              ret << "<tr class=#{cycle("grid_2","grid_3")}>"
              ret << "<td align='center'>#{journal.created_at.strftime("%d-%b-%Y")}</td>"
              ret << "<td style='color:maroon'>#{value.account.description}</td>"
              ret << "<td>#{journal.description}</td>"
              ret << "<td align='right'>#{format_currency(value.value)}</td>"
              ret << "<td align='right'>&nbsp;</td>"
              total_debit += value.value
              saldo = is_debit ? saldo + value.value : saldo - value.value
            elsif !value.is_debit
              ret << "<tr class=#{cycle("grid_2","grid_3")}>"
              ret << "<td align='center'>#{journal.created_at.strftime("%d-%b-%Y")}</td>"
              ret << "<td style='color:maroon'>#{value.account.description}</td>"
              ret << "<td>#{journal.description}</td>"
              ret << "<td align='right'>&nbsp;</td>"
              ret << "<td align='right'>#{format_currency(value.value)}</td>"
              total_credit += value.value
              saldo = is_debit ? saldo - value.value : saldo + value.value
            end
            ret << "<td align='right'>#{format_currency(saldo)}</td>"
            ret << "</tr>"
          end
        end

      end
    end
    return ret
  end

end
