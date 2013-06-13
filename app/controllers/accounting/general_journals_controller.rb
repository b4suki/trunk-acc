class Accounting::GeneralJournalsController < ApplicationController
  before_filter :initial_method

  def index
    if request.post? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]
    elsif request.get? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year
      $selected_month, $selected_year = nil, nil
    elsif request.get? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $month, $year = current_month, current_year      
    end
    
    @date = {:month => $month, :year => $year} 
    $SELECTED_ACCOUNT_PURCHASE = nil
    $FILTER_ACCOUNT_PURCHASE = false
    $FILTER_ACCOUNT_SALE = false
    conditions = []
    conditions << "MONTH(created_at) = #{@date[:month]}"
    conditions << "YEAR(created_at) = #{@date[:year]}"
    conditions = conditions.join(" AND ")
    $CONDITIONS_DATE = conditions
    @result = AccountingCashBalance.find(:all, :conditions => conditions) 
    @result += AccountingBankBalance.find(:all, :conditions => conditions)
    @result += AccountingSaleBalance.find(:all, :conditions => conditions)
    @result += AccountingPurchaseBalance.find(:all, :conditions => conditions)
    @result += AccountingManualJournal.find(:all, :conditions => conditions)
    @result.sort! { |x, y| x.created_at <=> y.created_at }
    $CONDITIONS_EVIDENCE = nil
    #    $CONDITIONS_DESCRIPTION = nil
    $CONDITIONS_JOB = nil
    $CONDITIONS_ACCOUNT = nil
    #    $CONDITIONS_DEBIT = nil
    #    $CONDITIONS_CREDIT = nil
    $SELECTED_DATE = "all"
    $SELECTED_EVIDENCE = "all"
    #    $SELECTED_DESCRIPTION = "all"
    $SELECTED_JOB = "all"
    $SELECTED_ACCOUNT = "all"
    #    $SELECTED_DEBIT = "all"
    #    $SELECTED_CREDIT = "all"
    $TOTAL_CREDIT = 0
    $TOTAL_DEBIT = 0    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @result }
      format.pdf  { 
        send_data render_to_pdf({
            :action => 'index.rpdf',
            :page => 'landscape',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename => "general_journal_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "general_journal_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end
  end
  
  def filter_date 
    purchase_objs = []
    sale_obj = []        
    if params[:value] == "all"
      conditions = []
      conditions << "MONTH(created_at) = #{params[:month]}"
      conditions << "YEAR(created_at) = #{params[:year]}"
      $CONDITIONS_DATE =  conditions.join(" AND ") 
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      #      conditions << $CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.join(" AND ")
      $SELECTED_DATE = "all"      
    else
      date = params[:value].split("-")
      conditions = []
      conditions << "DAY(created_at) = #{date[0]}"
      conditions << "MONTH(created_at) = #{month_index(date[1])}"
      conditions << "YEAR(created_at) = #{date[2]}"
      $CONDITIONS_DATE =  conditions.join(" AND ")
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      #      conditions <<  $CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.join(" AND ")      
      purchase_objs = account_filter_purchase($SELECTED_ACCOUNT_PURCHASE,$CONDITIONS_DEBIT)
      sale_obj = account_filter_sale($SELECTED_ACCOUNT_PURCHASE,$CONDITIONS_DEBIT)
      $SELECTED_DATE = "#{params[:value]}"       
    end 
    account = {:value => $SELECTED_ACCOUNT == "all" ? 0 : $SELECTED_ACCOUNT,
      :select => $CONDITIONS_ACCOUNT ? true : false}
    debit  = $CONDITIONS_DEBIT ? true : false 
    credit = $CONDITIONS_CREDIT ? true : false 
    @result = AccountingCashBalance.find(:all, :conditions => conditions ) 
    @result += sale_obj.empty? ? AccountingSaleBalance.find(:all, :conditions => conditions)  : sale_obj
    @result += AccountingBankBalance.find(:all, :conditions => conditions) 
    @result += purchase_objs.empty? ? AccountingPurchaseBalance.find(:all, :conditions => conditions) : purchase_objs
    @result += AccountingManualJournal.find(:all, :conditions => conditions)
    # @result.sort! { |x, y| x.created_at <=> y.created_at }
    @date = {:month => params[:month], :year => params[:year]} 
    render :update do |page|
      page.replace "option_date", :partial => "option_date", :locals => {:result => @result, :date => @date}
      page.replace "option_evidence", :partial => "option_evidence", :locals => {:result => @result, :date => @date }
      #      page.replace "option_description", :partial => "option_description", :locals => {:result => @result, :date => @date}
      page.replace "option_job", :partial => "option_job", :locals => {:result => @result, :date => @date}
      page.replace "option_account", :partial => "option_account", :locals => {:result => @result, :date => @date}
      page.replace_html "target_journal", :partial => "content_general_journal", :locals => {:result => @result, :date => @date, :account => account, :debit => debit, :credit => credit}
    end
  end
  
  def filter_evidence    
    purchase_objs = []
    sale_obj = []
    if params[:value] == "all"
      conditions = [] 
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      #      conditions <<  $CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.empty? ? nil : conditions.join(" AND ")      
      $CONDITIONS_EVIDENCE = nil
      $SELECTED_EVIDENCE = "all"
    elsif params[:value] == "blank"
      conditions = [] 
      conditions << "evidence is NULL"
      $CONDITIONS_EVIDENCE = conditions.join(" AND ") 
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      #      conditions <<  $CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.empty? ? nil : conditions.join(" AND ")  
      $SELECTED_EVIDENCE = "blank"
    elsif params[:value] == "non blank" 
      conditions = [] 
      conditions << "evidence is NOT NULL"
      $CONDITIONS_EVIDENCE = conditions.join(" AND ") 
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      conditions <<  $CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.empty? ? nil : conditions.join(" AND ")  
      $SELECTED_EVIDENCE = "non blank"        
    else
      conditions = []
      conditions << "evidence = '#{params[:value]}'"
      $CONDITIONS_EVIDENCE = conditions.join(" AND ")
      conditions << $CONDITIONS_DATE
      #      conditions <<  $CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.join(" AND ")
      purchase_objs = account_filter_purchase($SELECTED_ACCOUNT_PURCHASE,$CONDITIONS_DEBIT)
      sale_obj = account_filter_purchase($SELECTED_ACCOUNT_PURCHASE,$CONDITIONS_DEBIT)
      $SELECTED_EVIDENCE  = params[:value]     
    end
    account = {:value => $SELECTED_ACCOUNT == "all" ? 0 : $SELECTED_ACCOUNT,
      :select => $CONDITIONS_ACCOUNT ? true : false}
    debit  = $CONDITIONS_DEBIT ? true : false 
    credit = $CONDITIONS_CREDIT ? true : false 
    @result = AccountingCashBalance.find(:all, :conditions => conditions ) 
    @result += sale_obj.empty? ? AccountingSaleBalance.find(:all, :conditions => conditions) : sale_obj
    @result += AccountingBankBalance.find(:all, :conditions => conditions) 
    @result += purchase_objs.empty? ? AccountingPurchaseBalance.find(:all, :conditions => conditions) : purchase_objs
    @result += AccountingManualJournal.find(:all, :conditions => conditions)
    # @result.sort! { |x, y| x.created_at <=> y.created_at }
    @date = {:month => params[:month], :year => params[:year]} 
    render :update do |page|
      page.replace "option_date", :partial => "option_date", :locals => {:result => @result, :date => @date}
      page.replace "option_description", :partial => "option_description", :locals => {:result => @result, :date => @date}
      page.replace "option_job", :partial => "option_job", :locals => {:result => @result, :date => @date}
      page.replace "option_account", :partial => "option_account", :locals => {:result => @result, :date => @date}
      page.replace_html "target_journal", :partial => "content_general_journal", :locals => {:result => @result, :date => @date, :account => account, :debit => debit, :credit => credit}
    end   
  end
  
  def filter_description
    purchase_objs = []
    sale_obj = []
    if params[:value] == "all"
      conditions = []
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.empty? ? nil : conditions.join(" AND ")
      $CONDITIONS_DESCRIPTION = nil
      $SELECTED_DESCRIPTION = "all"
    elsif params[:value] == "blank"
      conditions = [] 
      conditions << "(description is NULL || description = '')"
      $CONDITIONS_DESCRIPTION = conditions.join(" AND ") 
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.empty? ? nil : conditions.join(" AND ")  
      $SELECTED_DESCRIPTION = "blank"
    elsif params[:value] == "non blank" 
      conditions = [] 
      conditions << "(description is NOT NULL || description != '')"
      $CONDITIONS_DESCRIPTION = conditions.join(" AND ") 
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.empty? ? nil : conditions.join(" AND ")  
      $SELECTED_DESCRIPTION = "non blank"
    else      
      conditions = []
      conditions << "description LIKE '%#{params[:value].strip}%'"
      $CONDITIONS_DESCRIPTION = conditions.join(" AND ")
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.join(" AND ")
      purchase_objs = account_filter_purchase($SELECTED_ACCOUNT_PURCHASE,$CONDITIONS_DEBIT)
      sale_obj = account_filter_sale($SELECTED_ACCOUNT_PURCHASE,$CONDITIONS_DEBIT)
      $SELECTED_DESCRIPTION  = params[:value]     
    end
    account = {:value => $SELECTED_ACCOUNT == "all" ? 0 : $SELECTED_ACCOUNT,
      :select => $CONDITIONS_ACCOUNT ? true : false}
    debit  = $CONDITIONS_DEBIT ? true : false 
    credit = $CONDITIONS_CREDIT ? true : false 
    @result = AccountingCashBalance.find(:all, :conditions => conditions ) 
    @result += AccountingSaleBalance.find(:all, :conditions => conditions) 
    @result += sale_obj.empty? ? AccountingBankBalance.find(:all, :conditions => conditions)  : sale_obj
    @result += purchase_objs.empty? ? AccountingPurchaseBalance.find(:all, :conditions => conditions) : purchase_objs
    @result += AccountingManualJournal.find(:all, :conditions => conditions)
    # @result.sort! { |x, y| x.created_at <=> y.created_at }
    @date = {:month => params[:month], :year => params[:year]} 
    render :update do |page|
      page.replace "option_date", :partial => "option_date", :locals => {:result => @result, :date => @date}
      #      page.replace "option_description", :partial => "option_description", :locals => {:result => @result, :date => @date}
      page.replace "option_evidence", :partial => "option_evidence", :locals => {:result => @result, :date => @date }
      page.replace "option_job", :partial => "option_job", :locals => {:result => @result, :date => @date}
      page.replace "option_account", :partial => "option_account", :locals => {:result => @result, :date => @date}
      page.replace_html "target_journal", :partial => "content_general_journal", :locals => {:result => @result, :date => @date, :account => account, :debit => false, :credit => false}
    end       
  end
  
  def filter_job
    purchase_objs = []
    sale_obj = []    
    if params[:value] == "all"
      conditions = []
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      #      conditions << $CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.empty? ? nil : conditions.join(" AND ")
      $CONDITIONS_JOB = nil
      $SELECTED_JOB = "all"
    elsif params[:value] == "blank"
      conditions = []
      conditions << "job_id IS NULL"
      $CONDITIONS_JOB = conditions.join(" AND ")
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      #      conditions << $CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.join(" AND ")
      $SELECTED_JOB  = "blank"     
    elsif params[:value] == "non blank" 
      conditions = []
      conditions << "job_id IS NOT NULL"
      $CONDITIONS_JOB = conditions.join(" AND ")
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      #      conditions << $CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.join(" AND ")
      $SELECTED_JOB  = "non blank"     
    else
      conditions = []
      conditions << "job_id = '#{params[:value]}'"
      $CONDITIONS_JOB = conditions.join(" AND ")
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      conditions << $CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.join(" AND ")
      purchase_objs = account_filter_purchase($SELECTED_ACCOUNT_PURCHASE,$CONDITIONS_DEBIT)
      sale_obj = account_filter_sale($SELECTED_ACCOUNT_PURCHASE,$CONDITIONS_DEBIT)
      $SELECTED_JOB  = params[:value]     
    end
    account = {:value => $SELECTED_ACCOUNT == "all" ? 0 : $SELECTED_ACCOUNT,
      :select => $CONDITIONS_ACCOUNT ? true : false}
    debit  = $CONDITIONS_DEBIT ? true : false 
    credit = $CONDITIONS_CREDIT ? true : false 
    @result = AccountingCashBalance.find(:all, :conditions => conditions ) 
    @result += sale_obj.empty? ? AccountingSaleBalance.find(:all, :conditions => conditions)  : sale_obj
    @result += AccountingBankBalance.find(:all, :conditions => conditions) 
    @result += purchase_objs.empty? ? AccountingPurchaseBalance.find(:all, :conditions => conditions) : purchase_objs
    @result += AccountingManualJournal.find(:all, :conditions => conditions)
    # @result.sort! { |x, y| x.created_at <=> y.created_at }
    @date = {:month => params[:month], :year => params[:year]} 
    render :update do |page|
      page.replace "option_date", :partial => "option_date", :locals => {:result => @result, :date => @date}
      page.replace "option_evidence", :partial => "option_evidence", :locals => {:result => @result, :date => @date }
      #      page.replace "option_description", :partial => "option_description", :locals => {:result => @result, :date => @date}
      page.replace "option_job", :partial => "option_job", :locals => {:result => @result, :date => @date}
      page.replace "option_account", :partial => "option_account", :locals => {:result => @result, :date => @date}
      page.replace_html "target_journal", :partial => "content_general_journal", :locals => {:result => @result, :date => @date, :account => account, :debit => false, :credit => false}
    end  
  end
  
  def filter_account
    purchase_objs = []
    sale_obj = []
    if params[:value] == "all"
      $FILTER_ACCOUNT_PURCHASE = false
      $SELECTED_ACCOUNT = "all"
      $FILTER_ACCOUNT_SALE = false
      conditions = []
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      #      conditions << $CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.empty? ? nil : conditions.join(" AND ")
      $CONDITIONS_ACCOUNT = nil
      $SELECTED_ACCOUNT = "all"
      select_account = false
    elsif params[:value] == "blank"
      $FILTER_ACCOUNT_PURCHASE = false
      $FILTER_ACCOUNT_SALE = false
      conditions = [] 
      conditions << "account_id is NULL"
      $CONDITIONS_ACCOUNT = conditions.join(" AND ") 
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      #      conditions << $CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.empty? ? nil : conditions.join(" AND ")
      $SELECTED_ACCOUNT = "blank"
    elsif params[:value] == "non blank" 
      conditions = [] 
      conditions << "account_id IS NOT NULL"
      $CONDITIONS_ACCOUNT = conditions.join(" AND ") 
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.empty? ? nil : conditions.join(" AND ")  
      $SELECTED_ACCOUNT = "non blank"
    else         
      $FILTER_ACCOUNT_PURCHASE = true
      $FILTER_ACCOUNT_SALE = true
      conditions = []                      
      $SELECTED_ACCOUNT_PURCHASE = params[:value]
      purchase_objs = account_filter_purchase(params[:value],$CONDITIONS_DEBIT)
      sale_obj = account_filter_sale(params[:value],$CONDITIONS_DEBIT)
      conditions << "(account_id = '#{params[:value]}' OR contra_account_id = '#{params[:value]}')"                                  
      $CONDITIONS_ACCOUNT = conditions.join(" AND ")
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      #      conditions << $CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.join(" AND ")
      $SELECTED_ACCOUNT  = params[:value]      
      select_account = true      
    end
    account = {:value => $SELECTED_ACCOUNT == "all" ? 0 : $SELECTED_ACCOUNT,
      :select => select_account }
    debit  = $CONDITIONS_DEBIT ? true : false 
    credit = $CONDITIONS_CREDIT ? true : false     
    @result = AccountingCashBalance.find(:all, :conditions => conditions+"  or (account_id is null or contra_account_id is null)" )     
    #@result += AccountingSaleBalance.find(:all, :conditions => conditions) 
    @result += AccountingBankBalance.find(:all, :conditions => conditions+"  or (account_id is null or contra_account_id is null)" ) 
    #@result += AccountingPurchaseBalance.find(:all, :conditions => conditions)
    #@result += AccountingPurchaseBalance.find(:all, :conditions => conditions)    
    @result += sale_obj.empty? ? AccountingSaleBalance.find(:all, :conditions => conditions) : sale_obj
    @result += purchase_objs.empty? ? AccountingPurchaseBalance.find(:all, :conditions => conditions) : purchase_objs
    @result += AccountingManualJournal.find(:all, :conditions => conditions)
    #@result.sort! { |x, y| x.created_at <=> y.created_at }
    @date = {:month => params[:month], :year => params[:year]} 
    render :update do |page|      
      page.replace "option_date", :partial => "option_date", :locals => {:result => @result, :date => @date}
      page.replace "option_evidence", :partial => "option_evidence", :locals => {:result => @result, :date => @date }
      #      page.replace "option_description", :partial => "option_description", :locals => {:result => @result, :date => @date}
      page.replace "option_job", :partial => "option_job", :locals => {:result => @result, :date => @date}
      page.replace "option_account", :partial => "option_account", :locals => {:result => @result, :date => @date}
      page.replace_html "target_journal", :partial => "content_general_journal", :locals => {:result => @result, :date => @date, :account => account, :debit => false, :credit => false}
    end 
  end
  
  def account_filter_purchase(value, conditions_debit)
    array_obj = []
    conditions_purchase = []
    account_purchase_id = AccountingPurchaseDebitCredit.find_by_account_id(value).nil? ? 0 : AccountingPurchaseDebitCredit.find_by_account_id(value).id             
    if value != "all"  && conditions_debit.nil?
      account_purchase_id = AccountingPurchaseDebitCredit.find_by_account_id(value).nil? ? 0 : AccountingPurchaseDebitCredit.find_by_account_id(value).id
      conditions_purchase << "accounting_purchase_debit_credit_values.purchase_debit_credit_id = #{account_purchase_id}  "
    elsif conditions_debit != nil   && value == "all"
      account_purchase_id = AccountingPurchaseDebitCreditValue.find_by_value($SELECTED_DEBIT).account_id
      #conditions_purchase << "accounting_purchase_debit_credit_values.purchase_debit_credit_id = #{account_purchase_id}  and accounting_purchase_debit_credit_values.value = #{$SELECTED_DEBIT}"
    elsif conditions_debit !=nil && value != "all" && value != nil
      account_purchase_id = AccountingPurchaseDebitCredit.find_by_account_id(value).nil? ? 0 : AccountingPurchaseDebitCredit.find_by_account_id(value).id
      conditions_purchase << "accounting_purchase_debit_credit_values.purchase_debit_credit_id = #{account_purchase_id}  and accounting_purchase_debit_credit_values.value = #{$SELECTED_DEBIT}"
    elsif conditions_debit !=nil && value == nil
      account_purchase_id = AccountingPurchaseDebitCreditValue.find_by_value($SELECTED_DEBIT).account_id
    end
   
    if account_purchase_id != 0
      #conditions_purchase << "accounting_purchase_debit_credit_values.purchase_debit_credit_id = #{account_purchase_id}  "
      conditions_purchase << "accounting_purchase_balances."+$CONDITIONS_DESCRIPTION  if $CONDITIONS_DESCRIPTION
      conditions_purchase << "accounting_purchase_balances."+$CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      conditions_purchase << "accounting_purchase_balances."+$CONDITIONS_JOB if $CONDITIONS_JOB
      conditions_purchase << $CONDITIONS_DATE.gsub(/created_at/, "accounting_purchase_balances.created_at") if $CONDITIONS_DATE
      conditions_purchase << "accounting_purchase_balances."+$CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions_purchase << conditions_debit.gsub(/transaction_value/, 'accounting_purchase_debit_credits.debit = 1 and accounting_purchase_debit_credit_values.value') if conditions_debit
      conditions_purchase = conditions_purchase.join(" AND ")
      @purchase_value_objs = AccountingPurchaseDebitCreditValue.find(:all,
        :conditions => conditions_purchase,
        :joins =>
          "inner join accounting_purchase_balances on accounting_purchase_balances.id = accounting_purchase_debit_credit_values.purchase_balance_id
                                                                     inner join accounting_purchase_debit_credits on accounting_purchase_debit_credits.id = accounting_purchase_debit_credit_values.purchase_debit_credit_id",
        :group => 'purchase_balance_id')
      #  p @purchase_value_objs
      if @purchase_value_objs
        @purchase_value_objs.each do |purchase_obj|
          array_obj << purchase_obj.accounting_purchase_balance
        end
      end
    end
    #   p "----===="
    #   p array_obj
    return array_obj
  end
 
  def account_filter_sale(value, conditions_credit)
    array_obj = []
    conditions_sale = []
    #    account_sale_id = AccountingSaleDebitCredit.find_by_account_id(value).nil? ? 0 : AccountingSaleDebitCredit.find_by_account_id(value).id
    #   if value != "all"  && conditions_credit.nil?
    #     account_sale_id = AccountingSaleDebitCredit.find_by_account_id(value).nil? ? 0 : AccountingSaleDebitCredit.find_by_account_id(value).id
    #     conditions_sale << "accounting_sale_debit_credit_values.sale_debit_credit_id = #{account_sale_id}  "
    #   elsif conditions_credit != nil   && value == "all"
    #    account_sale_id = AccountingSaleDebitCreditValue.find_by_value($SELECTED_DEBIT).accounting_sale_debit_credit.account_id
    #    #conditions_purchase << "accounting_purchase_debit_credit_values.purchase_debit_credit_id = #{account_purchase_id}  and accounting_purchase_debit_credit_values.value = #{$SELECTED_DEBIT}"
    #   elsif conditions_credit !=nil && value != "all" && value != nil
    #     account_sale_id = AccountingSaleDebitCredit.find_by_account_id(value).nil? ? 0 : AccountingSaleDebitCredit.find_by_account_id(value).id
    #     conditions_sale << "accounting_sale_debit_credit_values.sale_debit_credit_id = #{account_sale_id}  and accounting_sale_debit_credit_values.value = #{$SELECTED_DEBIT}"
    #   elsif conditions_credit !=nil && value == nil
    #        account_sale_id = AccountingSaleDebitCreditValue.find_by_value($SELECTED_DEBIT).accounting_sale_debit_credit.account_id
    #   end
   
    account_sale_id = AccountingSaleDebitCredit.find_by_account_id(value).nil? ? 0 : AccountingSaleDebitCredit.find_by_account_id(value).id
    if account_sale_id != 0
      conditions_sale << "accounting_sale_debit_credit_values.sale_debit_credit_id = #{account_sale_id}  "
      conditions_sale << $CONDITIONS_DATE.gsub(/created_at/, "accounting_sale_balances.created_at") if $CONDITIONS_DATE
      #      conditions_sale << "accounting_sale_balances."+$CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions_sale << "accounting_sale_balances."+$CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      conditions_sale << "accounting_sale_balances."+$CONDITIONS_JOB if $CONDITIONS_JOB
      #      conditions_sale << "accounting_sale_balances."+$CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      #      conditions_sale << "accounting_sale_balances."+$CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      conditions_sale = conditions_sale.join(" AND ")
      @sale_value_objs = AccountingSaleDebitCreditValue.find(:all,
        :conditions => conditions_sale,
        :joins => "inner join accounting_sale_balances on accounting_sale_balances.id = accounting_sale_debit_credit_values.sale_balance_id ",
        :group => 'sale_balance_id')
     
      if @sale_value_objs
        @sale_value_objs.each do |sale_obj|
          array_obj << sale_obj.accounting_sale_balance
        end
      end
    end
    return array_obj
  end
 
  def split_conditions(arrays, alt)
    result = ""
    case alt
    when "DESCRIPTION" then
      result = arrays[1].to_s.gsub(/['%]/, '')
    when "EVIDENCE", "JOB" then
      result = arrays[1].to_s.gsub(/[']/,'')
    when "CREDIT", "DEBIT" then
      result = arrays[1].to_f
    end
    return result
  end
 
 
  # def account_filter_array(ar_purchase)
  #   conditions, conditions_job = []
  #   conditions = []
  #   conditions << "item.description" if $CONDITIONS_DESCRIPTION
  #   conditions << "item.job" if $CONDITIONS_JOB
  #   conditions << "item.description == "+"#{split_conditions($CONDITIONS_DESCRIPTION.split(" LIKE "), "DESCRIPTION")}" if $CONDITIONS_DESCRIPTION
  #   conditions << "item.evidence =~ /["+split_conditions($CONDITIONS_EVIDENCE.split(" = "), "EVIDENCE")+"]/" if $CONDITIONS_EVIDENCE
  #   conditions << "item.job =~ /["+split_conditions($CONDITIONS_JOB.split(" = "),"JOB")+"]/" if $CONDITIONS_JOB
  #   conditions << "item.transaction_value =~ /["+split_conditions($CONDITIONS_CREDIT.split(" = ", "CREDIT"))+"]/" if $CONDITIONS_CREDIT
  #   conditions << "item.transaction_value =~ /["+split_conditions($CONDITIONS_DEBIT.split(" = ", "DEBIT"))+"]/" if $CONDITIONS_DEBIT
  #   conditions = conditions.join(" && ")
  #   #p conditions
  #   ar_tmp = []
  #   ar_tmp = "{ar_purchase.select{|item| #{conditions}}}"
  #   #p ar_purchase.size
  #   ar_purchase.each do |item|
  #   #  p eval(conditions) && eval(conditions_job)
  #     if eval(conditions)
  #          ar_tmp << item
  #      end
  #   end
  #   return eval(ar_tmp)
  # end
  
  def filter_debit
    purchase_objs = []
    sale_obj = []    
    if params[:value] == "all"
      conditions = []
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      #      conditions << $CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.empty? ? nil : conditions.join(" AND ")
      $CONDITIONS_DEBIT = nil
      $SELECTED_DEBIT = "all"      
    else
      conditions = []
      conditions << "transaction_value = #{params[:value]}"
      $CONDITIONS_DEBIT = conditions.join(" AND ")          
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      #      conditions << $CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_CREDIT if $CONDITIONS_CREDIT
      conditions = conditions.join(" AND ")
      $SELECTED_DEBIT  = params[:value]   
      purchase_objs = account_filter_purchase($SELECTED_ACCOUNT, $CONDITIONS_DEBIT)                 
      sale_obj = account_filter_sale($SELECTED_ACCOUNT, $CONDITIONS_DEBIT)                       
    end
    account = {:value => $SELECTED_ACCOUNT == "all" ? 0 : $SELECTED_ACCOUNT,
      :select => $CONDITIONS_ACCOUNT ? true : false}
    credit = $CONDITIONS_CREDIT ? true : false          
    @result = AccountingCashBalance.find(:all, :conditions => conditions ) 
    @result += sale_obj.empty? ? AccountingSaleBalance.find(:all, :conditions => conditions)  : sale_obj
    @result += AccountingBankBalance.find(:all, :conditions => conditions) 
    @result += purchase_objs.empty? ? AccountingPurchaseBalance.find(:all, :conditions => conditions) : purchase_objs
    @result += AccountingManualJournal.find(:all, :conditions => conditions)
    #@result.sort! { |x, y| x.created_at <=> y.created_at }
    @date = {:month => params[:month], :year => params[:year]} 
    render :update do |page|
      page.replace "option_date", :partial => "option_date", :locals => {:result => @result, :date => @date}
      page.replace "option_evidence", :partial => "option_evidence", :locals => {:result => @result, :date => @date }
      page.replace "option_job", :partial => "option_job", :locals => {:result => @result, :date => @date}
      page.replace "option_account", :partial => "option_account", :locals => {:result => @result, :date => @date}
      #      page.replace "option_description", :partial => "option_description", :locals => {:result => @result, :date => @date}
      page.replace_html "target_journal", :partial => "content_general_journal", :locals => {:result => @result, :date => @date, :account => account, :debit => false, :credit => false}
    end       
  end
  
  def filter_credit  
    purchase_obj = []
    sale_obj = []
    if params[:value] == "all"
      conditions = []
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      #      conditions << $CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      conditions = conditions.empty? ? nil : conditions.join(" AND ")
      $CONDITIONS_CREDIT = nil
      $SELECTED_CREDIT = "all"
      select_credit = false
    else
      conditions = []
      conditions << "transaction_value = #{params[:value]}"
      $CONDITIONS_CREDIT = conditions.join(" AND ")
      conditions << $CONDITIONS_DATE if $CONDITIONS_DATE
      conditions << $CONDITIONS_EVIDENCE if $CONDITIONS_EVIDENCE
      #      conditions << $CONDITIONS_DESCRIPTION if $CONDITIONS_DESCRIPTION
      conditions << $CONDITIONS_JOB if $CONDITIONS_JOB
      conditions << $CONDITIONS_ACCOUNT if $CONDITIONS_ACCOUNT
      #      conditions << $CONDITIONS_DEBIT if $CONDITIONS_DEBIT
      conditions = conditions.join(" AND ")
      $SELECTED_CREDIT  = params[:value]   
      purchase_obj = account_filter_purchase($SELECTED_ACCOUNT, $SELECTED_DEBIT)
      sale_obj = account_filter_sale($SELECTED_ACCOUNT, $SELECTED_DEBIT)
    end
    account = {:value => $SELECTED_ACCOUNT == "all" ? 0 : $SELECTED_ACCOUNT,
      :select => $CONDITIONS_ACCOUNT ? true : false}
    debit  = $CONDITIONS_DEBIT ? true : false              
    @result = AccountingCashBalance.find(:all, :conditions => conditions ) 
    @result += sale_obj.empty? ? AccountingSaleBalance.find(:all, :conditions => conditions) : sale_obj
    @result += AccountingBankBalance.find(:all, :conditions => conditions) 
    @result += purchase_obj.empty? ? AccountingPurchaseBalance.find(:all, :conditions => conditions) : purchase_obj
    @result += AccountingManualJournal.find(:all, :conditions => conditions)
    #  @result.sort! { |x, y| x.created_at <=> y.created_at }
    @date = {:month => params[:month], :year => params[:year]} 
    render :update do |page|
      page.replace "option_date", :partial => "option_date", :locals => {:result => @result, :date => @date}
      page.replace "option_evidence", :partial => "option_evidence", :locals => {:result => @result, :date => @date }
      page.replace "option_job", :partial => "option_job", :locals => {:result => @result, :date => @date}
      page.replace "option_account", :partial => "option_account", :locals => {:result => @result, :date => @date}
      #      page.replace "option_description", :partial => "option_description", :locals => {:result => @result, :date => @date}
      page.replace_html "target_journal", :partial => "content_general_journal", :locals => {:result => @result, :date => @date, :account => account, :debit => false, :credit => false}
    end       
  end

  def post_trial_balance
    @accounts = AccountingAccount.find(:all, :conditions => ["parent_id is NULL"], :order => "code ASC")
    @date = {:month => "", :year => ""} 
    @date = params[:trial_balance] ? params[:trial_balance] :  {:month => current_month , :year => current_year}
    
    date = params[:trial_balance] ? Time.mktime(params[:trial_balance][:year], params[:trial_balance][:month], 1, 0, 0, 0, 0) : Time.now
    @previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}
    
    conditions = []
    conditions << "MONTH(created_at) = #{@date[:month]}"
    conditions << "YEAR(created_at) = #{@date[:year]}"
    conditions = conditions.join(" AND ")
    $CONDITIONS_DATE = conditions
    @result = AccountingCashBalance.find(:all, :conditions => conditions ) 
    @result += AccountingSaleBalance.find(:all, :conditions => conditions) 
    @result += AccountingBankBalance.find(:all, :conditions => conditions) 
    @result += AccountingPurchaseBalance.find(:all, :conditions => conditions)
    @result += AccountingManualJournal.find(:all, :conditions => conditions)
    # @result.sort! { |x, y| x.created_at <=> y.created_at }
    prepare_post_to_trial_balance(@accounts, @result, @previous_date, @date, false)
    redirect_to :action => "index"
  end
  
  private
  
  def prepare_post_to_trial_balance(groups, result, previous_date, date, report = false)
    level = 0
    $SUMMARY_PREVIOUS = 0
    $SUMMARY_DEBET    = 0
    $SUMMARY_CREDIT   = 0
    $SUMMARY_SALDO    = 0

    for group in groups
      if group.parent_id.nil?
        first_saldo = get_as_adjusted_saldo(group, previous_date)
        summary          = prepare_show_summary(result, group)
        if group.accounting_account_classification.is_debit
          last_saldo       = first_saldo+(summary[1]-summary[0])
        else
          last_saldo       = first_saldo+(summary[0]-summary[1])
        end

        $SUMMARY_PREVIOUS += first_saldo
        $SUMMARY_DEBET    += summary[1]
        $SUMMARY_CREDIT   += summary[0]
        $SUMMARY_SALDO    += last_saldo
        create_trial_balance(group, last_saldo, date)
        find_all_sub_account_prepare_post_to_trial_balance(result,previous_date,date, group, level, report)
      end
    end

  end
  
  def find_all_sub_account_prepare_post_to_trial_balance(result,previous_date, date, group, level, report)
    level += 1
    group.children.each do |sugroup|      
      first_saldo = get_as_adjusted_saldo(sugroup, previous_date)
      summary = prepare_show_summary(result, sugroup)
      if sugroup.accounting_account_classification.is_debit
        last_saldo       = first_saldo+(summary[1]-summary[0])
      else
        last_saldo       = first_saldo+(summary[0]-summary[1])
      end
      $SUMMARY_PREVIOUS += first_saldo
      $SUMMARY_DEBET    += summary[1]
      $SUMMARY_CREDIT   += summary[0]
      $SUMMARY_SALDO    += last_saldo
      create_trial_balance(sugroup, last_saldo, date)
      find_all_sub_account_prepare_post_to_trial_balance(result,previous_date,date,sugroup, level, report)
    end
  end
  
  def prepare_show_summary(result, account)
    account = {:select => false, :value => account.id}
    summary = []
    summary_debet = 0
    summary_credit = 0
    result.each do |journal|
      summary = summary_general_journal_from_cash_balance(journal, account)
      summary_credit += summary[0]
      summary_debet += summary[1]
      summary = summary_general_journal_from_bank_balance(journal, account)
      summary_credit += summary[0]
      summary_debet += summary[1]
      summary = summary_general_journal_from_sale_balance(journal, account)
      summary_credit += summary[0]
      summary_debet += summary[1]
      summary = summary_general_journal_from_purchase_balance(journal, account)
      summary_credit += summary[0]
      summary_debet += summary[1]
      summary = summary_general_journal_from_manual_journal(journal, account)
      summary_credit += summary[0]
      summary_debet += summary[1]
    end    
    return summary_credit, summary_debet
  end
  
  def summary_general_journal_from_cash_balance(journal, account)
    ret_debet = 0
    ret_kredit = 0
    if journal.class == AccountingCashBalance
      if journal.account_id == account[:value].to_i
        ret_debet += journal.transaction_value
      elsif journal.contra_account_id == account[:value].to_i
        ret_kredit += journal.transaction_value
      end
    end
    return  ret_kredit, ret_debet
  end

  def summary_general_journal_from_bank_balance(journal, account)
    ret_debet = 0
    ret_kredit = 0
    if journal.class == AccountingBankBalance
      if journal.account_id == account[:value].to_i
        ret_debet += journal.transaction_value
      elsif journal.contra_account_id == account[:value].to_i
        ret_kredit += journal.transaction_value
      end
    end
    return ret_kredit, ret_debet
  end
  
  def summary_general_journal_from_sale_balance(journal, account)
    ret_debet = 0
    ret_kredit = 0
    if journal.class == AccountingSaleBalance
      journal.values.each do |value|
        #        if value.accounting_sale_debit_credit.account_id == account[:value].to_i
        if value.account_id == account[:value].to_i
          if value.is_debit
            ret_debet += value.value
          else
            ret_kredit += value.value
          end
        end
      end
    end    
    return ret_kredit, ret_debet
  end

  
  def summary_general_journal_from_purchase_balance(journal, account)        
    ret_debet = 0
    ret_kredit = 0
    if journal.class == AccountingPurchaseBalance
      journal.values.each do |value|
        #        if value.accounting_purchase_debit_credit.account_id == account[:value].to_i
        if value.account_id == account[:value].to_i
          if value.is_debit
            ret_debet += value.value
          else
            ret_kredit += value.value
          end
        end
      end
    end    
    return ret_kredit, ret_debet
  end

  def summary_general_journal_from_manual_journal(journal, account)
    ret_debet = 0
    ret_kredit = 0
    if journal.class == AccountingManualJournal
      journal.values.each do |value|
        if value.account_id == account[:value].to_i
          if value.is_debit
            ret_debet += value.value
          elsif !value.is_debit
            ret_kredit += value.value
          end
        end
      end
    end
    return ret_kredit, ret_debet
  end
  
  def get_first_saldo(group, period)
    first_saldo = group.trial_balances.find(
      :first, 
      :conditions => ["MONTH(transaction_date)=#{period[:month]} AND YEAR(transaction_date)=#{period[:year]}"]
    )
    first_saldo = first_saldo.nil? ? 0 : first_saldo.last_saldo
  end
  
  def create_trial_balance(group, last_saldo, date)
    first_saldo = group.trial_balances.find(
      :first, 
      :conditions => ["MONTH(transaction_date) = #{date[:month]} AND YEAR(transaction_date) = #{date[:year]}"]
    ) 
     report = ReportOfYear.find( :first,:conditions => ["YEAR(date_report) = #{date[:year]} AND account_id = '#{group.id}'"])
      if report.nil?
        ReportOfYear.create(:account_id => group.id,:value => last_saldo, :date_report => Time.mktime(date[:year], 12, 6, 0, 0, 0, 0))
      else
        report.update_attribute(:value, last_saldo)
      end
    if first_saldo.nil?
      trial_balance = TrialBalance.new(:last_saldo => last_saldo, :transaction_date => Time.mktime(date[:year], date[:month], 6, 0, 0, 0, 0))
      group.trial_balances << trial_balance
      group.save
    else
      first_saldo.update_attribute(:last_saldo, last_saldo)  
    end
  end

  
  def initial_method
    @title = "GENERAL JOURNAL"
    @periode = true
  end
end
