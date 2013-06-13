class Accounting::ReceivableMutationsController < ApplicationController
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
    conditions = []
    conditions << "MONTH(accounting_sale_balances.updated_at) = #{$month}"
    conditions << "YEAR(accounting_sale_balances.updated_at) = #{$year}"
    conditions = conditions.join(" AND ")

    @receivables = AccountingSaleBalance.find(:all, :include => :accounting_mutation, :conditions => conditions, :group => 'customer_id')

    respond_to do |format|
      format.html
      format.xml  { render :xml => @receivables }
      format.pdf  {
        send_data render_to_pdf({
          :action => 'index.rpdf',
          :page => 'portrait',
          :size => '30x60cm',
          :layout => 'pdf_report'
        }), :filename => "mutasi_piutang_jatuh_tempo_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "mutasi_piutang_jatuh_tempo_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end 
  end
  
  private
  
  def initial_method
    @title = "DAFTAR MUTASI PIUTANG JATUH TEMPO"
    @periode = true
  end	
  
end
