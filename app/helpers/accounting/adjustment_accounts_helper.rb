module Accounting::AdjustmentAccountsHelper
  def options_for_type
    options = {:Debit => "Debit", :Credit => "Credit"}          
  end 
  
  def find_combo_type(debit_credit)      
     choice = "Debit"
     unless debit_credit.nil?
       debits = AdjustmentAccount.find(:first, :conditions => ["id =?",debit_credit])
      if debits.debit_credit == true #and debits != nil
         choice ="Credit"            
      end          
     end
     choice
   end
   
  def set_table_aje_manual(next_num, export)    
    table = "<tr class=#{cycle("grid_3","grid_2")} >"
    conditions = []
    conditions << "MONTH(adjustment_date)=#{$month} and YEAR(adjustment_date) =#{$year}"
    adjustments = AccountingAdjustmentBalance.find(:all, :conditions => conditions)
    adjustments.each do |adjustment|
      table << "<tr class=#{cycle("grid_2","grid_3")} >"
      table << "<td>#{next_num}</td>"
      table << "<td>31- #{selected_month[0,3]} - #{$year} </td>"
      table << "<td style='text-align:center;'>#{adjustment.job_no}</td>"
      table << "<td>#{adjustment.description}</td>"      
      table << "<td>&nbsp;</td>"
      table << "<td>#{adjustment.accounting_account.code}</td>"        
      table << "<td style='text-align:right;'>#{format_currency(adjustment.values)}</td>"
      table << "<td>&nbsp;</td>"      
      table << "<td> #{link_to_remote_redbox("Edit", {:url => "/accounting/adjustment_balances/edit/#{adjustment.id}"},{:class => "a_edit"})} </td>" if export
      table << "<td> #{link_to 'Hapus', accounting_adjustment_balance_path(adjustment), :confirm => "Apakah anda yakin '#{adjustment.description}' akan dihapus?", :method => :delete, :class => "a_delete"} </td>" if export
      table << "</tr>"
      $TOTAL_FIXED_ASSETS_DEBIT = $TOTAL_FIXED_ASSETS_DEBIT + (adjustment.values.nil? ? 0 :adjustment.values)      
      next_num = next_num + 1
      if adjustment.contra_account_id
        table << "</tr>"
        table << "<tr class=#{cycle("grid_2","grid_3")} >"
        table << "<td>#{next_num}</td>"
        table << "<td>31- #{selected_month[0,3]} - #{$year} </td>"        
        table << "<td style='text-align:center;'>#{adjustment.job_no}</td>"
        table << "<td>#{adjustment.description}</td>"
        table << "<td>&nbsp;</td>"
        table << "<td>#{adjustment.contra_account.code}</td>"        
        table << "<td>&nbsp;</td>"
        table << "<td style='text-align:right;'>#{format_currency(adjustment.values)}</td>"        
        table << "<td> #{link_to_remote_redbox("Edit", {:url => "/accounting/adjustment_balances/edit/#{adjustment.id}"},{:class => "a_edit"})} </td>" if export  
        table << "<td> #{link_to 'Hapus', accounting_adjustment_balance_path(adjustment), :confirm => "Apakah anda yakin '#{adjustment.description}' akan dihapus?", :method => :delete, :class => "a_delete"} </td>" if export 
        $TOTAL_FIXED_ASSETS_CREDIT = $TOTAL_FIXED_ASSETS_CREDIT + (adjustment.values.nil? ? 0 :adjustment.values)
        next_num = next_num + 1
      end  
    end
    table << "</tr>"            
    table
  end
  
  def get_subtotal_assets
    $TOTAL_FIXED_ASSETS_DEBIT = 0
    fixed_detail = AccountingFixedAssetDetail.find(:all, :conditions => ['month(transaction_date) = ? and year(transaction_date)= ?', $month, $year])
    fixed_detail.each do |fixed|
      if fixed.transaction_date.strftime('%d') <= "15" && fixed.transaction_date != $month 
        $TOTAL_FIXED_ASSETS_DEBIT += ((fixed.accounting_fixed_asset.value - fixed.accounting_fixed_asset.scrap_value) *(1.to_f/fixed.accounting_fixed_asset.valuable_age.to_f))*0.083333            
      end
    end
    $TOTAL_FIXED_ASSETS_DEBIT
  end
end
