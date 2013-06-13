module SaleBalancesHelper

  def account_bank
    options = AccountingSaleDebitCredit.find(:all,:conditions => ["account_type = 'Bank' OR account_type = 'cash'"] ).collect {|p| [ p.accounting_account.description, p.id ] }
  end

  def account_bank_transfer
    options = AccountingSaleDebitCredit.find(:all,:conditions => ["account_type = 'Bank'"] ).collect {|p| [ p.accounting_account.description, p.id ] }
  end

  def check_account_cash(sale_id)
    cheak,transfer = false, nil

    accounts =  AccountingSaleDebitCredit.find(:all, :conditions => ["account_type = 'cash' OR account_type = 'Bank'  AND debit = '1'"])
    accounts.each  { |account| 
      transfer = AccountingSaleBalance.find(sale_id).values.find_by_sale_debit_credit_id(account.id)
      cheak = true if !transfer.nil?
    }
    return cheak
  end

  def check_account_cash_all(sale_id)
    check,transfer = false, nil

    accounts =  AccountingSaleDebitCredit.find(:all, :conditions => ["account_type = 'cash'"])
    accounts.each  { |account|
      transfer = AccountingSaleBalance.find(sale_id).values.find_by_sale_debit_credit_id(account.id)
      check = true if !transfer.nil?
    }
    return check
  end
  def check_receivable_all(receivable_id)
    check,transfer = false, nil
    accounts =  AccountingSaleDebitCredit.find(:all, :conditions => ["account_type = 'cash'"])
    accounts.each  { |account|
      transfer = Receivable.find(receivable_id).manual_journal.values.find_by_account_id(account.id)
      check = true if !transfer.nil?
    }
    return check
  end

  def check_account_shipping_all(sale_id)
    cheak,transfer = false, nil

    accounts =  AccountingSaleDebitCredit.find(:all, :conditions => ["account_type = 'shipping'"])
    accounts.each  { |account|
      transfer = AccountingSaleBalance.find(sale_id).values.find_by_sale_debit_credit_id(account.id)
      cheak = true if !transfer.nil?
    }
    return cheak
  end

  def transfer_all_list(sale)
    transfer,  accoutn_id = '', ''
    total = 0
    ret = ''
    $selected_account  << sale.id
    accounts =   AccountingSaleDebitCredit.find(:all, :conditions => ["account_type = 'cash' or  account_type = 'shipping' AND debit = '1'"])
    accounts.each  { |account| transfer = AccountingSaleBalance.find(sale.id).values.find_by_sale_debit_credit_id(account.id) 
      if !transfer.nil?
        accoutn_id = account.id
        ret << "#{hidden_field "transfer_#{transfer.id}","total_value", :value => transfer.value, :style => "text-align: right;",:size => 13,:readonly => true }"
         total +=  transfer.value
      end
    }
        ret << '<div style ="float: left;padding: 1px 5px;"> '
        ret << '<table class="search_table" cellpadding="5" cellspacing="0">'
        ret << "<tr>"
        ret << "<td>No Invoice</td>"
        ret << "<td>:</td>"
        ret << "<td>#{sale.invoice_number}</td>"
        ret << "</tr>"
        ret << "<tr>"
        ret << "<td>Customer</td>"
        ret << "<td>:</td>"
        ret << "<td>#{sale.customer.name}</td>"
        ret << "</tr>"
        ret << "<tr>"
        ret << "<td>Total</td>"
        ret << "<td> : </td>"
        ret << "<td > #{text_field_tag "transfer_#{sale.id}", total, :style => "text-align: right;",:size => 13,:readonly => true }  </td>"
        ret << "<tr>"
        ret << "<td>Telah Di Transfer</td>"
        ret << "<td>:</td>"
        ret << "<td>#{check_box_tag "check_#{sale.id}"}</td>"
        ret << "</tr>"
        ret << "</table>"
        ret << "<br/>"
        ret << "</div>"
    return ret
  end
  
  def transfer_all_list_piutang(receivable)
    ret = ''
    $piutang  << receivable.id
    receivable.manual_journal.values.each do |value|
      if value.is_debit && value.account.description == "Bank"
        ret << '<div style ="float: left;padding: 1px 3px;"> '
        ret << '<table class="search_table" cellpadding="5" cellspacing="0">'
        ret << "<tr>"
        ret << "<td>No Bukti</td>"
        ret << "<td>:</td>"
        ret << "<td>#{receivable.evidence}#{hidden_field_tag "id_#{receivable.id}" , value.id}</td>"
        ret << "</tr>"
        ret << "<tr>"
        ret << "<td>Customer</td>"
        ret << "<td>:</td>"
        ret << "<td>#{receivable.customer.name}</td>"
        ret << "</tr>"
        ret << "<tr>"
        ret << "<td>Total</td>"
        ret << "<td> : </td>"
        ret << "<td > #{text_field "transfer_#{receivable.id}","value", :value => value.value, :style => "text-align: right;",:size => 13,:readonly => true }  </td>"
        ret << "<tr>"
        ret << "<td>Telah Di Transfer</td>"
        ret << "<td>:</td>"
        ret << "<td>#{check_box_tag "check_#{receivable.id}"}</td>"
        ret << "</tr>"
        ret << "</table>"
        ret << "<br/>"
        ret << "</div>"
      end
    end if !receivable.manual_journal.nil?
    return ret
  end


  def options_for_customer
    options = Customer.find(:all).collect {|p| [ p.name, p.id ] }
    options.unshift(["- Pilih -",""])
  end
  
  def options_for_sale_debet(stat)
    options = AccountingSaleDebitCredit.find(:all,:conditions =>["accounting_sale_debit_credits."+stat+"=1"]).collect {|p| [ p.description, p.id ] }
    options.unshift(["- Pilih -",""])
  end
 
  def options_for_signatures
    options = AccountingSaleSignature.find(:all).collect { |sig| ["#{sig.signatory} - #{sig.position}", sig.id]  }
  end

  def accumulate_sale_subtotal
    object = AccountingSaleBalance.get_sum_all(:month => $month, :year => $year)
    handle_with_zero(object, 'total_subtotal')
  end
  
  def accumulate_sale_discount
    object = AccountingSaleBalance.get_sum_all(:month => $month, :year => $year)
    handle_with_zero(object, 'total_discount')
  end
  
  def accumulate_sales
    object = AccountingSaleBalance.get_sum_all(:month => $month, :year => $year)
    handle_with_zero(object, 'final_total_sale')
  end

  def table_values_debet_credit(id_sale, debet_credit)
    sales_debit = ""
    debit_types = AccountingSaleDebitCredit.find(:all,:conditions => ["accounting_sale_debit_credits."+debet_credit+"=1"]).collect { |accont_name| accont_name.account_id}.uniq
    unless debit_types.empty?
      debit_types.each do  |type|
        value = AccountingSaleDebitCreditValue.sum('value',
          :conditions => ["sale_balance_id = ? AND account_id = ?", id_sale, type])
        sales_debit << "<td align='right'>#{value ? format_currency(value) : format_currency(0)}</td>"
#        value = AccountingSaleDebitCreditValue.find(:first,
#          :conditions => ["sale_balance_id = ? AND sale_debit_credit_id = ?", id_sale, type.id])
        #        set_total_field_for sale_balance, :transaction_value

      end
    end
    sales_debit
  end

  def options_for_terms_of_payments_sales
    options = AccountingTermsOfPayment.find(:all).collect {|p| [ p.name.to_s, p.days.nil? ? 0 : p.days ] }
    options.unshift(["Cash","0"])
  end
  
  def sum_debet_credit(debet_credit)
    sales_debit = ""
    debit_types = AccountingSaleDebitCredit.find(:all,:conditions => ["accounting_sale_debit_credits."+debet_credit+"=1"]).collect { |account| account.account_id }.uniq
    unless debit_types.empty?
      debit_types.each_with_index do  |type, i|
        value = AccountingSaleDebitCreditValue.sum('value',
          :conditions => ["MONTH(created_at)=#{$month} AND YEAR(created_at)=#{$year} AND account_id = ?", type])
        sales_debit << "<th style='text-align:right;'>#{value ? format_currency(value) : format_currency(0)}</th>"
#        value = AccountingSaleDebitCreditValue.get_sum_all_credit_debit(:month => $month, :year => $year, :debit_credit => type.id)
#        sales_debit << "<th style='text-align:right;'>#{format_currency(value)} </th>"
      end
    end
    sales_debit
  end

  def export_sum_debet_credit(debet_credit)
    sales_debit = ""
    debit_types = AccountingSaleDebitCredit.find(:all,:conditions => ["accounting_sale_debit_credits."+debet_credit+"=1"])
    unless debit_types.empty?
      debit_types.each_with_index do  |type, i|
        value = AccountingSaleDebitCreditValue.get_sum_all_credit_debit(:month => $month, :year => $year, :debit_credit => type.id)
        sales_debit << "<th align='right'>#{value} </th>"
      end
    end
    sales_debit
  end
 
  def view_header(debet_credit)
    header =[  ]

    sale_type = AccountingSaleDebitCredit.find(:all, :conditions => ["accounting_sale_debit_credits."+debet_credit+"=1"]).collect { |accont_name| accont_name.accounting_account.description}.uniq
    unless sale_type.empty?
      sale_type.each do |i|
#        header <<  "<th align='center'>#{i.accounting_account.description }</th>"
        header <<  "<th align='center'>#{i }</th>"
      end
    end
    header
  end
   
  def handle_params_month_and_year
    @month = params[:date] && params[:date][:month] ? params[:date][:month].to_i : current_month
    @year = params[:date] && params[:date][:year] ? params[:date][:year].to_i : current_year
  end
  
  def handle_with_zero(object, field)
    value = object.nil? ? 0 : object.send(field)
  end
  
  def selected_account_sale(sale_balance)
    sale_balance.nil? || sale_balance.contra_account.nil? ? "" : find_selected_contra_sale(sale_balance.contra_account_id)
  end
  
  def find_selected_contra_sale(code)
    x = AccountingAccount.find(:first, :conditions => ['id = ?',code])
    x.code.to_s+"   "+x.description.to_s
  end
  
  def default_filter_month
    $month.to_i
  end
  
  def default_filter_year
    $year.to_i
  end

  def create_space(level)
    a = ""
    0.upto(level) do |i|
      a += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
    end
    a
  end
  
  def load_product(sale_balance)
    desc = ""
    sale_balance.accounting_sale_balance_details.each do |sale|
      desc << "<p>#{sale.qty}&nbsp;#{sale.product_name}</p><br />"
    end
    desc
  end
  
  def get_code_ppn_pph(code1, code2)
    ppn_pph = []
    account_ids = AccountingAccount.find(:all, :conditions =>['code in (?,?)',code1, code2])
    account_ids.each do |account_id1|
      ppn_pph << account_id1.id
    end
    account_ids = AccountingSaleDebitCredit.find(:all, :conditions => ['account_id in(?,?)', ppn_pph[0], ppn_pph[1]])
    ppn_pph = []
    account_ids.each do |account_id2|
      ppn_pph << account_id2.id
    end
    return ppn_pph
  end
      
end
