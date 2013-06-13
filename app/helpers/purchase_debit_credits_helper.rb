module PurchaseDebitCreditsHelper
  def find_combo_purchase(id)          
    choice = "Debit"
    unless id.nil?
      debits = AccountingPurchaseDebitCredit.find(:first, :conditions => ["id =?",id])
      if debits.credit == true and debits != nil
        choice ="Credit"
      end          
    end
    choice
  end

  def get_purchase_debit_or_credit(account_type)
    case account_type
    when 'purchase'
      ret = "debit"
    when 'shipping_debit'
      ret = "debit"
    when 'shipping_credit'
      ret = "credit"
    when 'discount'
      ret = "credit"
    when 'cash'
      ret = "credit"
    when 'payable'
      ret = "credit"
    end
    ret = "credit" if account_type[0..6]=='payment'
    return ret
  end
  
  def display_single_purchase_debit_credit_type(title, account, account_type)
    ret = ""
    ret << "<tr class='grid_footer'><th colspan='6'>Account #{title}</th></tr>"
    if account
      ret << "<tr class=#{cycle("grid_2","grid_3")}>"
      ret << "<td style='width :100px;'>#{h(account.accounting_account.code)}</td>"
      ret << "<td style='width :200px;'>#{h(account.accounting_account.description)}</td>"
      ret << "<td style='width :40px; text-align :center;'>#{check_box_tag 'Debit',:value_debet ,account.debit,:disabled => true}</td>"
      ret << "<td style='width :40px; text-align :center;'>#{check_box_tag 'Kredit',:value_credit ,account.credit,:disabled => true}</td>"
      ret << "<td style='width :50px;'>#{link_to_remote_redbox("Edit", {:url => "/accounting/purchase_debit_credits/edit/#{account.id}"},{:class => "a_edit"})}</td>"
      ret << "<td style='width :50px;'>#{link_to 'Hapus', accounting_purchase_debit_credit_path(account), :confirm => "Apakah anda yakin '#{account.accounting_account.description}' akan dihapus?", :method => :delete, :class => "a_delete"}</td>"
      ret << "</tr>"
    else
      ret << "<tr class=#{cycle("grid_2","grid_3")}>"
      ret << "<td colspan='6'>Belum Ditentukan #{link_to_remote_redbox("Input Account #{title}", {:url => {:action => :new, :account_type => account_type}}, {:class => "a_add"})}</td>"
      ret << "</tr>"
    end
    return ret
  end
end
