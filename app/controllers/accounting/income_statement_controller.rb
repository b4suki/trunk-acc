class Accounting::IncomeStatementController < ApplicationController
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
                
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @date}
      format.pdf  { 
        send_data render_to_pdf({
            :action => 'index.rpdf', 
            :page => 'portrait',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename =>  "income_statement_#{selected_export_month(@date[:month].to_s).downcase}_#{@date[:year]}.pdf"
      }      
      format.xls { render_to_xls(:filename => "income_statement_#{selected_export_month(@date[:month].to_s).downcase}_#{@date[:year]}.xls") }      
    end
  end 
  private

  def initial_method
    @title = "INCOME STATEMENT"
    @periode = true
  end
end
