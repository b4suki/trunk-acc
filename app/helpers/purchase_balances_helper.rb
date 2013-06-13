module PurchaseBalancesHelper
  
  def options_for_purchase_vendors
    options = Vendor.find(:all).collect {|p| [ p.name, p.id ] }
    options.unshift(["- Pilih -",""])
  end  
    
  def options_for_debet_purchase(stat)       
    options = AccountingPurchaseDebitCredit.find(:all,:conditions =>["accounting_purchase_debit_credits."+stat+"=1"]).collect {|p| [ p.description, p.id ] }     
    options.unshift(["- Pilih -",""])
  end  
  
  def accumulate_purchase_subtotal      
    object = AccountingPurchaseBalance.get_sum_all_purchase(:month => $month, :year => $year)
    handle_with_zero(object, 'total_subtotal')    
  end
  
  def accumulate_purchase_discount        
    object = AccountingPurchaseBalance.get_sum_all_purchase(:month => $month, :year => $year)
    handle_with_zero(object, 'total_discount')    
  end
  
  def accumulate_purchase    
    object = AccountingPurchaseBalance.get_sum_all_purchase(:month => $month, :year => $year)
    handle_with_zero(object, 'final_total_purchase')    
  end
  
  def default_filter_month
    $month.to_i
  end
  
  def default_filter_year
    $year.to_i
  end
  
  def table_values_debet_credit_purchase(id_purchase, debet_credit)
    @asdf ||= {}
    @asdf[debet_credit] ||= []
    sales_debit = ""

    debit_types = AccountingPurchaseDebitCredit.find(:all,
      :conditions => ["accounting_purchase_debit_credits."+debet_credit+"=1"],
      :order => "account_id"
    )


    account = debit_types.map(&:account_id).uniq
    unless account.empty?
      account.each_with_index do  |type, i|
        value = AccountingPurchaseDebitCreditValue.find(:all,
          #          :select => 'SUM(accounting_purchase_debit_credit_values.value) "all_value", purchase_balance_id, purchase_debit_credit_id',
          :conditions => ["purchase_balance_id = ? AND account_id = ?", id_purchase, type],
          :group => "purchase_balance_id, purchase_debit_credit_id"
        )
        @asdf[debet_credit][i] = @asdf[debet_credit][i].to_i + value.sum(&:value).to_i
        sales_debit << "<td align='right'>#{value ? format_currency(value.sum(&:value).to_i) : '&nbsp;'}</td>"

      end
    end  
    sales_debit
  end
  
  def selected_account_purchase(purchase_balance)    
    purchase_balance.nil? || purchase_balance.contra_account.nil? ? "" : find_selected_contra(purchase_balance.contra_account_id)
  end
  
  def find_selected_contra(code)
    x = AccountingAccount.find(:first, :conditions => ['id = ?',code])
    x.code.to_s+"   "+x.description.to_s
  end
  
  #  def values_debit_credit(id_sale)
  #    sales_debit = ""  
  #    x = AccountingSaleDebitCredit.find(:all,
  #                                       :include => :accounting_sale_debit_credit_values,
  #                                       :conditions => ["accounting_sale_debit_credit_values.sale_balance_id = ?", id_sale])    
  #                                       p x
  #    x.each do |type|
  #      sales_debit << "<td>#{type ? type.total_subtotal : ''} </td>"      
  #    end    
  #  end 
  #    
  
  def count_group(purchase_balance)
    #    depth = AccountingPurchaseBalance.find(:all, :conditions => ["invoice_numbe = ?",purchase_balance])
    depth = AccountingPurchaseBalance.find_all_by_invoice_number(purchase_balance).size        
    depth
  end
  
  
  def load_product_purchase(purchase_balance)
    desc = ""
    products = AccountingPurchaseBalance.find(:all, :conditions => ["invoice_number = ?",purchase_balance.invoice_number])          
    products.each_with_index do |product, i|
      desc << "<td>#{product.qty}&nbsp;#{product.description}</td>"
    end
    desc
  end
  
  def loop_product(products, params1)
    desc = ""
    desc << "<table>"
    products.each do |product|
      desc << "<tr><td>#{product.qty} &nbsp; #{product.description}</td></tr>"
    end
    desc << "<table>"    
    desc
  end

  def sum_debet_credit_purchase(purchase_balances, debet_credit)
    sales_debit = ""
    if true
      ((@asdf || {})[debet_credit] || []).each do |asdf|
        sales_debit << "<th style='text-align:right;'>#{format_currency(asdf)}</th>"
      end
    else
      debit_types = AccountingPurchaseDebitCredit.find(:all,
        :conditions => ["accounting_purchase_debit_credits."+debet_credit+"=1"],
        :order => "account_id"
      )
      unless debit_types.empty?
        debit_types.each_with_index do  |type, i|
          value = AccountingPurchaseDebitCreditValue.get_grouped_sum_all_credit_debit(:month => $month, :year => $year, :debit_credit => type.id)
          sales_debit << "<th style='text-align:right;'>#{format_currency(value)}</th>"
        end
      end
    end
    sales_debit
  end

  def export_sum_debet_credit_purchase(debet_credit)
    sales_debit = ""
    debit_types = AccountingPurchaseDebitCredit.find(:all,:conditions => ["accounting_purchase_debit_credits."+debet_credit+"=1"])
    unless debit_types.empty?
      debit_types.each_with_index do  |type, i|
        value = AccountingPurchaseDebitCreditValue.get_sum_all_credit_debit(:month => $month, :year => $year, :debit_credit => type.id)
        sales_debit << "<th align='right'>#{value}</th>"
      end
    end
    sales_debit
  end
  
  def count_header_purchase(debet_credit)
    count = AccountingPurchaseDebitCredit.find(:all,:conditions => ["accounting_purchase_debit_credits."+debet_credit+" =1"]).size
  end  
  
  def view_header_purchase(debet_credit)
    header= ""
    purchase_type = AccountingPurchaseDebitCredit.find(:all,
      :select => 'accounting_accounts.description "accounting_account_description", accounting_purchase_debit_credits.account_id',
      :joins => :accounting_account,
      :conditions => ["accounting_purchase_debit_credits."+debet_credit+" = 1"],
      :group => "accounting_purchase_debit_credits.account_id",
      :order => "accounting_purchase_debit_credits.account_id"
    )
    unless purchase_type.empty?
      purchase_type.each do |i|
        header << "<th align='center'>#{ i.accounting_account_description }</th>"
      end
    end           
    header
  end  

  def options_for_terms_of_payments
    options = AccountingTermsOfPayment.find(:all).collect {|p| [ p.name.to_s, p.days.nil? ? 0 : p.days ] }
    options.unshift(["Cash","0"])
  end

  def get_days(purchase)      
    # purchase.accounting_terms_of_payment.days
  end
  
  def date_substract(days)
    x = ""
    date = []
    days = days.day.since(Time.now)
    date[0] = days.strftime('%d')
    date[1] = days.strftime('%m')
    date[2] = days.strftime('%Y')
    x = date.join('-')
    x
  end
  
  def get_code_ppn_pph_purchase(code1, code2)
    ppn_pph = []    
    account_ids = AccountingAccount.find(:all, :conditions =>['code in (?,?)',code1, code2])     
    account_ids.each do |account_id1|      
      ppn_pph << account_id1.id
    end        
    account_ids = AccountingPurchaseDebitCredit.find(:all, :conditions => ['account_id in(?,?)', ppn_pph[0], ppn_pph[1]])
    ppn_pph = []        
    account_ids.each do |account_id2|      
      ppn_pph << account_id2.id
    end       
    return ppn_pph
  end

  #  def get_total_tax_purchase()
  #    ref = []
  #
  #    tax_purchase = AccountingTax.all
  #    account_id = tax_purchase.collect { |x|  x.account_id.blank? ? nil : x.account_id }.uniq
  #    account_id.each do |account|
  #      debit_types = AccountingPurchaseDebitCredit.find_by_account_id(account)
  #      unless debit_types.nil?
  #        account_debit =0
  #
  #        value = AccountingPurchaseDebitCreditValue.get_sum_all_credit_debit(:month => $month, :year => $year, :debit_credit => debit_types)
  #        account_debit = account_debit + value
  #
  ##              <th>Total #{debit_types.description.upcase}</th>
  #        ref << "<tr>
  #               <th>Total PPN Masukan</th>
  #               <td align='right' class='grid_2_sum'>#{ format_currency(account_debit)} <td>
  #            </tr>"
  #      end
  #    end
  #    return ref
  #  end

  #  def accumulate_taxes
  #    ref = []
  #
  #    tax_purchase = AccountingTax.all
  #    account_id = tax_purchase.collect { |x|  x.account_id.blank? ? nil : x.account_id }.uniq
  #    account_id.each do |account|
  #      debit_types = AccountingPurchaseDebitCredit.find_by_account_id(account)
  #      credit_types = AccountingSaleDebitCredit.find_by_account_id(account)
  #      unless debit_types.nil? && credit_types.nil?
  #        account_debit =0
  #        account_credit =0
  ##        acccumulate_account =0
  #
  #        value1 = AccountingPurchaseDebitCreditValue.get_sum_all_credit_debit(:month => $month, :year => $year, :debit_credit => debit_types)
  #        account_debit = account_debit + value1
  #        value2 = AccountingSaleDebitCreditValue.get_sum_all_credit_debit(:month => $month, :year => $year, :debit_credit => debit_types)
  #        account_credit = account_credit + value2
  #        acccumulate_account = account_debit - account_credit
  #
  #        ref << "<tr>
  #              <th>Selisih PPN</th>
  #               <td align='right' class='grid_2_sum'>#{ format_currency(acccumulate_account)} <td>
  #            </tr>"
  #      end
  #     return ref
  #    end
  #  end
     
end
