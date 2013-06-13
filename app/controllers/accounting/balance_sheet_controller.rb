class Accounting::BalanceSheetController < ApplicationController
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
    
    @date = {:month => "", :year => ""}     
    @date = {:month => $month, :year => $year}
    
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @date }
      format.pdf  { 
        send_data render_to_pdf({
            :action => 'index.rpdf', 
            :page => 'portrait',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename =>  "balance_sheet_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }      
      format.xls { render_to_xls(:filename => "balance_sheet_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end
  end

  private

  def initial_method
    @title = "BALANCE SHEET"
    @periode = true
  end
end
