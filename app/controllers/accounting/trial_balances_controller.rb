class Accounting::TrialBalancesController < ApplicationController
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

    @trial_balance = TrialBalance.first
    @accounts = AccountingAccount.find(:all, :conditions => ["parent_id is NULL"], :order => "code ASC")
#    @date = {:month => "", :year => ""}
#    @date = params[:date] ? params[:date] :  {$month => current_month , $year => current_year}
    @date = params[:date] ? params[:date] :  {:month => current_month , :year => current_year}
    date = params[:date] ? Time.mktime(params[:date][:year], params[:date][:month], 1, 0, 0, 0, 0) : Time.now
    @previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}
    
    conditions = []
    conditions << "MONTH(created_at) = #{$month}"
    conditions << "YEAR(created_at) = #{$year}"
    conditions = conditions.join(" AND ")
    $CONDITIONS_DATE = conditions
    @result = AccountingCashBalance.find(:all, :conditions => conditions ) 
    @result += AccountingSaleBalance.find(:all, :conditions => conditions) 
    @result += AccountingBankBalance.find(:all, :conditions => conditions) 
    @result += AccountingPurchaseBalance.find(:all, :conditions => conditions)    
    @result += AccountingManualJournal.find(:all, :conditions => conditions)
    @result.sort! { |x, y| x.created_at <=> y.created_at }
    
    $CONDITIONS_EVIDENCE = nil
    $CONDITIONS_DESCRIPTION = nil
    $CONDITIONS_JOB = nil
    $CONDITIONS_ACCOUNT = nil
    $CONDITIONS_DEBIT = nil
    $CONDITIONS_CREDIT = nil
    $SELECTED_DATE = "all"
    $SELECTED_EVIDENCE = "all"
    $SELECTED_DESCRIPTION = "all"
    $SELECTED_JOB = "all"
    $SELECTED_ACCOUNT = "all"
    $SELECTED_DEBIT = "all"
    $SELECTED_CREDIT = "all"
    $TOTAL_CREDIT = 0
    $TOTAL_DEBIT = 0
	
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @accounts }
      format.pdf  { 
        send_data render_to_pdf({
            :action => 'index.rpdf', 
            :page => 'portrait',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename =>  "trial_balance_#{$month}_#{$year}.pdf"
      }      
      format.xls { render_to_xls(:filename => "trial_balance_#{selected_export_month($month.to_s).downcase}_#{$year}.xls") }
    end
  end

  def initial_saldo
    @accounts = AccountingAccount.all(:order => :code)
    render :layout => false
  end

  def create_saldo

    count = params[:account_count].nil? ? 0 : params[:account_count].to_i
    date = Time.mktime( params[:year] != "" ? params[:year] : current_year , params[:month] != "" ? params[:month] : current_month , 6, 0, 0, 0, 0)
    previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}
    1.upto(count) do |i|
      trial_balance = TrialBalance.new(
        :account_id => params["account_id_#{i}"],
        :last_saldo => params["saldo_#{i}"],
        :as_adjusted => params["saldo_#{i}"],
        :transaction_date => Time.mktime(previous_date[:year], previous_date[:month], 6, 0, 0, 0, 0)
      )
      trial_balance.save
    end if count > 0
    redirect_to :action => :index
  end

  def edit
    @trial_balance = TrialBalance.find(params[:id])
    render :layout => false
  end

  def update
    trial_balance = TrialBalance.find(params[:id])
    params[:trial_balance][:as_adjusted] =  params[:trial_balance][:last_saldo]
    trial_balance.update_attributes(params[:trial_balance])
    redirect_to :action => :index
  end

  private
  
  def initial_method
    @title = "TRIAL BALANCE"
    @periode = true
  end
end
