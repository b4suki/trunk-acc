class Accounting::CostEvaluationsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_account_code]
 
  #  access_control [:index, :pdf] => "Administrator | Direktur "
  def index
    initiate_method
    if request.post? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]
    elsif request.get? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year
      $selected_month, $selected_year = nil, nil
    elsif request.get? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $month, $year = current_month, current_year
    end
    #@cost_evaluations = AccountingAccount.find(:all, :conditions => ["code_a in (4,5,6,8)"], :group => :code_a)     
    @cost_evaluations = AccountingAccount.find(:all, :conditions => ["code in (41100,51000,52000,61000,62000,81100)"])          
    
    
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cost_evaluations }
      format.pdf  {        
        send_data render_to_pdf({
            :action => 'index.rpdf',
            :page => 'portrait',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename => "cost_evaluations_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "cost_evaluations_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end
  end
  
  def pdf 
    @cost_evaluations = AccountingAccount.find(:all, :conditions => ["code in (41100,51000,52000,61000,62000,81100)"])              
    make_and_send_pdf('/accounting/cost_evaluations/show', 'test')      
  end


  def show_period_accounts
    $total_account = {}
    @conditions = []
    1.upto(5) { |i| @conditions << "#{params['classification']["option_#{i}"].to_s }" if !params['classification']["option_#{i}"].nil? }  if !params['classification'].nil?
    conditions = @conditions.join(",")
    @title = "Laporan Periode"
    @date_years = !params[:date].nil? ? params[:date][:year_end] >= params[:date][:year] ? ("#{params[:date][:year]}".."#{params[:date][:year_end]}").to_a : ("#{params[:date][:year]}").to_a  : ("#{current_year}".."#{current_year.to_i + 4}").to_a
    @periode = !params[:date].nil? ? @date_years.size == 1 ? "Tahun #{@date_years.first(1)}" : "Tahun #{@date_years.first(1)} - #{@date_years.last(1)}" : "Tahun #{current_year}- #{current_year.to_i + 4 }"
    @cost_evaluations = conditions != ""  ? AccountingAccount.find(:all, :conditions =>["account_classification_id in (#{conditions})"], :order => "code") :  AccountingAccount.find(:all, :order => "code")
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cost_evaluations }
      format.pdf  {
        send_data render_to_pdf({
            :action => 'show_period_accounts.rpdf',
            :page => 'landscape',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename => "cost_period_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "cost_period_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end
  end

  def auto_complete_for_account_code
    search = params[:account][:code]
    @accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "autocomplete"
  end

  def initiate_method
    @title = "Cost Evaluation"
    @periode = true
  end
end
