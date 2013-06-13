class Accounting::GeneralLedgersController < ApplicationController
  before_filter :initial_method
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_account_code]

  def index
    if request.post? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]
      @selected_account = AccountingAccount.find(params[:account_id])
    elsif request.get? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year
      $selected_month, $selected_year = nil, nil
      @selected_account = AccountingAccount.first
    elsif request.get? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $month, $year = current_month, current_year
      @selected_account = AccountingAccount.first
    elsif request.get? && !params[:format].nil? 
       $month, $year = params[:date][:month], params[:date][:year]
      @selected_account = AccountingAccount.find(params[:account_id])
    end

    @date = {:month => $month, :year => $year}
    conditions = []
    conditions << "MONTH(created_at) = #{@date[:month]}"
    conditions << "YEAR(created_at) = #{@date[:year]}"
    conditions = conditions.join(" AND ")
    @result = AccountingCashBalance.find(:all, :conditions => conditions)
    @result += AccountingBankBalance.find(:all, :conditions => conditions)
    @result += AccountingSaleBalance.find(:all, :conditions => conditions)
    @result += AccountingPurchaseBalance.find(:all, :conditions => conditions)
    @result += AccountingManualJournal.find(:all, :conditions => conditions)
    @result.sort! { |x, y| x.created_at <=> y.created_at }

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @result }
      format.pdf  {
        send_data render_to_pdf({
            :action => 'index.rpdf',
            :page => 'landscape',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename => "general_ledger_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "general_ledger_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end
    
  end

  def auto_complete_for_account_code
    search = params[:account][:code]
    @accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "autocomplete"
  end

  private
  def initial_method
    @title = "GENERAL LEDGER"
    @periode = true
  end
end
