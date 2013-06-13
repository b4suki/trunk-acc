module Accounting::TaxReportsHelper
  def create_tax_report(journals, ppn_masukan_account, ppn_keluaran_account, date)
    previous_date = Time.mktime(date[:year], date[:month], 1, 0, 0, 0, 0)
    previous_date = {:month => previous_current_month(previous_date).strftime("%m"), :year => previous_current_month(previous_date).strftime("%Y")}
    $PPN_MASUKAN, $PPN_KELUARAN = 0, 0
    ppn_masukan_saldo = get_as_adjusted_saldo(ppn_masukan_account, previous_date)
    ppn_keluaran_saldo = get_as_adjusted_saldo(ppn_keluaran_account, previous_date)
    saldo = ppn_masukan_saldo - ppn_keluaran_saldo
    $SAlDO = saldo
    total_debit, total_credit = 0, 0
   
    is_debit = ppn_masukan_account.accounting_account_classification.is_debit
    ret = "<tr class='grid_3'><td>&nbsp;</td><td colspan='2'>Saldo Awal</td>"
    if saldo >= 0
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
        if journal.accounting_account == ppn_masukan_account || journal.accounting_account == ppn_keluaran_account
          saldo = is_debit ? saldo + journal.transaction_value : saldo - journal.transaction_value
          total_debit += journal.transaction_value
          $PPN_MASUKAN += journal.transaction_value
          create_table_tax_juranal(journal.created_at,journal.accounting_account.description,journal.description,
            format_currency(journal.transaction_value),format_currency(saldo), 'magenta', true)
        elsif journal.contra_account == ppn_masukan_account || journal.contra_account == ppn_keluaran_account
          saldo = is_debit ? saldo - journal.transaction_value : saldo + journal.transaction_value
          total_credit += journal.transaction_value
          $PPN_KELUARAN += journal.transaction_value
          create_table_tax_juranal(journal.created_at,journal.accounting_account.description,journal.description,
            format_currency(journal.transaction_value),format_currency(saldo), 'magenta', false)
        end

      when "AccountingBankBalance"
        if journal.accounting_account == ppn_masukan_account || journal.accounting_account == ppn_keluaran_account
          saldo = is_debit ? saldo + journal.transaction_value : saldo - journal.transaction_value
          total_debit += journal.transaction_value
          $PPN_MASUKAN += journal.transaction_value
          create_table_tax_juranal(ret,journal.created_at,journal.accounting_account.description,journal.description,
            format_currency(journal.transaction_value),format_currency(saldo), 'green', true)
        elsif journal.contra_account == ppn_masukan_account || journal.contra_account == ppn_keluaran_account
          saldo = is_debit ? saldo - journal.transaction_value : saldo + journal.transaction_value
          total_credit += journal.transaction_value
          $PPN_KELUARAN += journal.transaction_value
          create_table_tax_juranal(ret,journal.created_at,journal.accounting_account.description,journal.description,
            format_currency(journal.transaction_value),format_currency(saldo), 'green', false)
        end

      when "AccountingSaleBalance"
        journal.values.each do |jurnal|
          if jurnal.account == ppn_masukan_account || jurnal.account == ppn_keluaran_account
            jurnal.is_debit ? total_debit += jurnal.value &&  $PPN_MASUKAN += jurnal.value : total_credit += jurnal.value && $PPN_KELUARAN += jurnal.value
            saldo = jurnal.is_debit ? is_debit ? saldo + jurnal.value : saldo - jurnal.value : saldo = is_debit ? saldo - jurnal.value : saldo + jurnal.value
            create_table_tax_juranal(ret,journal.created_at,jurnal.account.description,journal.description,format_currency(jurnal.value),format_currency(saldo), 'blue', jurnal.is_debit ? true : false)
          end
        end

      when "AccountingPurchaseBalance"
        journal.values.each do |jurnal|
          if jurnal.account == ppn_masukan_account || jurnal.account == ppn_keluaran_account
            jurnal.is_debit ? total_debit += jurnal.value &&  $PPN_MASUKAN += jurnal.value : total_credit += jurnal.value && $PPN_KELUARAN += jurnal.value
            saldo = jurnal.is_debit ? is_debit ? saldo + jurnal.value : saldo - jurnal.value : saldo = is_debit ? saldo - jurnal.value : saldo + jurnal.value
            create_table_tax_juranal(ret,journal.created_at,jurnal.account.description,journal.description,format_currency(jurnal.value),format_currency(saldo), 'red', jurnal.is_debit ? true : false)
          end
        end

      when "AccountingManualJournal"
        journal.values.each do |value|
          if value.account == ppn_masukan_account || value.account == ppn_keluaran_account
            value.is_debit ? total_debit += value.value &&  $PPN_MASUKAN += value.value : total_credit += value.value && $PPN_KELUARAN += value.value
            saldo = value.is_debit ? is_debit ? saldo + value.value : saldo - value.value : saldo = is_debit ? saldo - value.value : saldo + value.value
            create_table_tax_juranal(ret,journal.created_at,value.account.description,journal.description,format_currency(value.value),format_currency(saldo), 'maroon',value.is_debit ? true : false)
          end
        end

      end
    end
    return ret
  end
  
  def get_total_tax()
    ref = []
    accumulate =   $SAlDO + $PPN_MASUKAN - $PPN_KELUARAN
    ref << "<tr>
               <th>Total PPN Masukan</th>
               <td align='right' class='grid_2_sum'>#{ format_currency($PPN_MASUKAN)} <td>
            </tr>"
    ref << "<tr>
               <th>Total PPN Keluaran</th>
               <td align='right' class='grid_2_sum'>#{ format_currency($PPN_KELUARAN)} <td>
                    </tr>"
    ref << "<tr>
               <th>Selisih  #{accumulate > 0 ? 'Pendapatan PPN' : 'Pembayaran PPN'  }</th>
               <td align='right' class='grid_2_sum'>#{ format_currency(accumulate )} <td>
             </tr>"
    return ref
  end
  
  def create_table_tax_juranal(ret,date,ppn,description,transaction,saldo,color, debit)
    ret << "<tr class=#{cycle("grid_2","grid_3")}>"
    ret << "<td align='center'>#{format_date(date)}</td>"
    ret << "<td style='color:#{color};'>#{ppn}</td>"
    ret << "<td>#{description}</td>"
    ret << "<td align='right'>#{debit == true ? transaction : '&nbsp;' }</td>"
    ret << "<td align='right'>#{debit == false ? transaction : '&nbsp;' }</td>"
    ret << "<td align='right'>#{saldo}</td>"
    ret << "</tr>"
  end
end
