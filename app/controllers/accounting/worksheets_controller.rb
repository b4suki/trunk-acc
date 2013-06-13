class Accounting::WorksheetsController < ApplicationController
  before_filter :initial_method
#  access_control [:index] => "Administrator | Direktur "
  def index

    if request.post? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]
    elsif request.get? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year
      $selected_month, $selected_year = nil, nil
    elsif request.get? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $month, $year = current_month, current_year
    end

    $SUM_TRIAL_BALANCE_DEBET  = 0
    $SUM_TRIAL_BALANCE_CREDIT = 0
    $SUM_AJE_DEBET            = 0
    $SUM_AJE_CREDIT           = 0
    $SUM_AS_ADJUSTED_DEBET    = 0
    $SUM_AS_ADJUSTED_CREDIT   = 0
    $SUM_INCOME_STATEMENT_DEBET = 0
    $SUM_INCOME_STATEMENT_CREDIT = 0
    $SUM_BALANCE_SHEET_DEBET = 0
    $SUM_BALANCE_SHEET_CREDIT = 0
    @accounts = AccountingAccount.find(:all, :conditions => ["parent_id is NULL"], :order => "code ASC")
#    @date = {:month => "", :year => ""}
    @date = params[:date] ? params[:date] :  {:month => current_month , :year => current_year}
    
    date = params[:date] ? Time.mktime(params[:date][:year], params[:date][:month].to_i + 1, 1, 0, 0, 0, 0) : Time.now
    @previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}
    
     respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @accounts }
      format.pdf  { 
        send_data render_to_pdf({
            :action => 'index.rpdf', 
            :page => 'landscape',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename =>  "worksheet_#{selected_export_month($month).downcase}_#{$year}.pdf"
      }
      format.xls { render_to_xls(:filename => "worksheet_#{selected_export_month(@date[:month].to_s).downcase}_#{@date[:year]}.xls") }
    end    
  end
  
  private
  
  def initial_method
    @title = "WORKSHEET"
    @periode = true
  end
end
