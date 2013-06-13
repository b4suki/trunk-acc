class Accounting::TaxReportsController < ApplicationController
  before_filter :login_required, :initial_method

  def index
    @credit = AccountingPurchaseDebitCredit.count(:all, :conditions => ["credit IS true"])
    @debit = AccountingPurchaseDebitCredit.count(:all, :conditions => ["debit IS true"])
    @credit = AccountingSaleDebitCredit.count(:all, :conditions => ["credit IS true"])
    @debit = AccountingSaleDebitCredit.count(:all, :conditions => ["debit IS true"])
    get_total_field
    if request.post? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]
    elsif request.get? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year
      $selected_month, $selected_year = nil, nil
    elsif request.get? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $month, $year = current_month, current_year
    end

    conditions = []
    conditions << "MONTH(invoice_date)=#{$month}"
    conditions << "YEAR(invoice_date)=#{$year}"
    conditions = conditions.join(" AND ")
    @tax = AccountingTax.all
    @ppn_masukan = !@tax.empty? ? AccountingTax.find_by_account_type("ppn_masukan").account : "" rescue nil
    @ppn_keluaran = !@tax.empty? ? AccountingTax.find_by_account_type("ppn_keluaran").account : "" rescue nil

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
      format.html
      format.xml  { render :xml => @result }
      format.pdf  {
        send_data render_to_pdf({
            :action => 'index.rpdf',
            :page => 'landscape',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename => "laporan_ppn_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "laporan_ppn_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end
  end

  private

  def initial_method
    @title = "LAPORAN PPN"
    @periode = true
  end
end
