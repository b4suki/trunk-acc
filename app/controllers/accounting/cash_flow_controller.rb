class Accounting::CashFlowController < ApplicationController
  before_filter :login_required, :initial_method

  def index
    if request.post? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]
    elsif request.get? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year
      $selected_month, $selected_year = nil, nil
    elsif request.get? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $month, $year = current_month, current_year
    end

    @date = params[:date] ? params[:date] :  {:month => current_month, :year => current_year}

    @operating_activity = AccountingCashFlowActivity.find_by_name("operasi")
    @investing_activity = AccountingCashFlowActivity.find_by_name("investasi")
    @financing_activity = AccountingCashFlowActivity.find_by_name("pendanaan")

    $TOTAL_OPERATING_ACTIVITY = 0
    $TOTAL_INVESTING_ACTIVITY = 0
    $TOTAL_FINANCING_ACTIVITY = 0

    respond_to do |format|
      format.html
      format.xml  { render :xml => @operating_activity + @investing_activity + @financing_activity }
      format.pdf  {
        send_data render_to_pdf({
            :action => 'index.rpdf',
            :page => 'portrait',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename => "cash_flow_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "cash_flow_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end
  end

  private
  def initial_method
    @title = "CASH FLOW"
    @periode = true
  end
end
