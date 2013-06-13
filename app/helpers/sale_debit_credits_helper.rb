module SaleDebitCreditsHelper  
  def options_for_account_type
    options = {:Debit => "Debit", :Credit => "Credit"}          
  end
  
  def find_combo(id)
    choice = "Debit"
    unless id.nil?
      debits = AccountingSaleDebitCredit.find(:first, :conditions => ["id =?",id])
      if debits.credit == true and debits != nil
        choice ="Credit"
      end          
    end
    choice
  end

  def get_sale_account_type(type)
    case type
    when 'cash'
      account_type = "debit"
    when 'receivable'
      account_type = "debit"
    when 'shipping'
      account_type = "debit"
    when 'shipping_contra'
      account_type = "credit"
    when 'discount'
      account_type = "debit"
    when 'ppn_keluaran'
      account_type = "credit"
    when 'Bank'
      account_type = "debit"
    end

    account_type = "credit" if type[0..3]=='sale'
    account_type = "debit" if type[0..6]=='payment'
    account_type = "debit" if type[0..3]=='cogs'
    account_type = "credit" if type[0..3]=='cogs' && type[-6..-1]=='contra'
    return account_type
  end

  def display_single_sale_debit_credit_type(title, account, account_type)
    ret = ""
    ret << "<tr class='grid_footer'><td colspan='6'>Account #{title}</td></tr>"
    if account_type != "Bank" && account_type != "shipping_bank"
      ret << "<tr class=#{cycle("grid_2","grid_3")}>"
      ret << "<td style='width :100px;'>#{account.accounting_account.code}</td>"
      ret << "<td style='width :200px;'>#{account.accounting_account.description}</td>"
      ret << "<td style='width :40px; text-align :center;'>#{check_box_tag 'Debit',:value_debet ,account.debit,:disabled => true}</td>"
      ret << "<td style='width :40px; text-align :center;'>#{check_box_tag 'Kredit',:value_credit ,account.credit,:disabled => true}</td>"
      ret << "<td>#{link_to_remote_redbox("Edit",{:url => "/accounting/sale_debit_credits/edit/#{account.id}"},{:class => "a_edit"})}</td>"
      ret << "<td>#{link_to 'Hapus', accounting_sale_debit_credit_path(account.id), :confirm => "Apakah anda yakin '#{account.accounting_account.description}' akan dihapus?", :method => :delete , :class => "a_delete"}</td>"
      ret << "</tr>"
    elsif account_type == "Bank"
      sale_debit_credit_accounts = AccountingSaleDebitCredit.find_all_by_account_type('Bank')
      sale_debit_credit_accounts.each do |count|
      ret << "<tr class=#{cycle("grid_2","grid_3")}>"
      ret << "<td style='width :100px;'>#{count.accounting_account.code}</td>"
      ret << "<td style='width :200px;'>#{count.accounting_account.description}</td>"
      ret << "<td style='width :40px; text-align :center;'>#{check_box_tag 'Debit',:value_debet ,count.debit,:disabled => true}</td>"
      ret << "<td style='width :40px; text-align :center;'>#{check_box_tag 'Kredit',:value_credit ,count.credit,:disabled => true}</td>"
      ret << "<td style='width :40px; text-align :center;'>&nbsp;</td>"
      ret << "<td style='width :40px; text-align :center;'>&nbsp;</td>"
      ret << "</tr>"
      end
    elsif account_type == "shipping_bank"
      sale_debit_credit_accounts = AccountingSaleDebitCredit.find_all_by_account_type('shipping_bank')
      sale_debit_credit_accounts.each do |count|
      ret << "<tr class=#{cycle("grid_2","grid_3")}>"
      ret << "<td style='width :100px;'>#{count.accounting_account.code}</td>"
      ret << "<td style='width :200px;'>#{count.accounting_account.description}</td>"
      ret << "<td style='width :40px; text-align :center;'>#{check_box_tag 'Debit',:value_debet ,count.debit,:disabled => true}</td>"
      ret << "<td style='width :40px; text-align :center;'>#{check_box_tag 'Kredit',:value_credit ,count.credit,:disabled => true}</td>"
      ret << "<td style='width :40px; text-align :center;'>&nbsp;</td>"
      ret << "<td style='width :40px; text-align :center;'>&nbsp;</td>"
      ret << "</tr>"
      end
    else
      ret << "<tr class=#{cycle("grid_2","grid_3")}>"
      ret << "<td colspan='6'>Belum Ditentukan #{link_to_remote_redbox("Input Account #{title}", {:url => {:action => :new, :account_type => account_type, :title => title}}, {:class => "a_add"})}</td>"
      ret << "</tr>"
    end
    return ret
  end
end
