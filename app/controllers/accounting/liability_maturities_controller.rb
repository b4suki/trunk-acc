class Accounting::LiabilityMaturitiesController < ApplicationController
  before_filter :login_required, :initial_method

  def index
    if request.post? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]
      $type = params[:filter][:type]
    elsif request.get? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year
      $selected_month, $selected_year = nil, nil
    elsif request.get? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $type = "maturity_date"
      $month, $year = current_month, current_year
    end
    conditions = []
    conditions << "MONTH(maturity_date) = #{$month}"
    conditions << "YEAR(maturity_date) = #{$year}"
    conditions << "amount_account_receivable > 0"
    conditions = conditions.join(" AND ")

    @liabilities = AccountingPurchaseBalance.find(:all, :conditions => conditions)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @liabilities }
      format.pdf  {
        send_data render_to_pdf({
            :action => 'index.rpdf',
            :page => 'portrait',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename => "utang_jatuh_tempo_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "utang_jatuh_tempo_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end 
  end

  def edit
    @liability = Liability.find(params[:id])
    @purchase = @liability.purchase
    render :layout => false
  end

  def update
    @liability = Liability.find(params[:id])
    @liability.created_at = params[:liability_updated_at]

    @liability.manual_journal.update_attributes(
      :evidence => params[:liability][:evidence],
      :created_at => params[:liability_updated_at]
    )

    purchase = @liability.purchase
    journal_value = purchase.currency.name.downcase == "rupiah" ? params[:liability][:payed_value] : params[:liability][:payed_value].to_i * purchase.kurs.to_i

    @liability.manual_journal.values.each do |value|
      value.update_attribute("value", journal_value)
    end

    purchase_attributes = {}
    if params[:liability][:payed_value].to_f > @liability.payed_value
      diff = params[:liability][:payed_value].to_f - @liability.payed_value
      purchase_attributes[:amount_account_receivable] = purchase.amount_account_receivable - diff
      purchase_attributes[:paid] = purchase.paid + diff
    elsif params[:liability][:payed_value].to_f < @liability.payed_value
      diff = @liability.payed_value - params[:liability][:payed_value].to_f
      purchase_attributes[:amount_account_receivable] = purchase.amount_account_receivable + diff
      purchase_attributes[:paid] = purchase.paid - diff
    end

    respond_to do |format|
      if @liability.update_attributes(params[:liability]) & purchase.update_attributes(purchase_attributes)
        flash[:notice] = 'Pembayaran utang berhasil diupdate.'
        format.xml  { head :ok }
      else
        flash[:error] = 'Pembayaran utang gagal diupdate.'
        format.xml  { render :xml => @liability.errors, :status => :unprocessable_entity }
      end
      case params[:from]
      when 'm'
        format.html { redirect_to(accounting_liability_maturities_path) }
      when 'p'
        format.html { redirect_to(accounting_purchase_balances_path) }
      end
    end
  end
  
  def do_pay
    liability = AccountingPurchaseBalance.find(params[:id])
    render :update do |page|
      page.replace_html "target", :partial => "do_pay", :locals => {:liability => liability}
    end
  end
  
  def cancel_pay
    render :update do |page|
      page.replace_html "target", ""
    end  
  end
  
  def ajax_select_status
    render :update do |page|
      if params[:id] == "2"
        @paid = Liability.new
        page.replace_html "target_replace", :partial => "paid_date"
      else
        page.replace_html "target_replace", ""  
      end  
    end     
  end
  
  private
  
  def make_parameter(paid, liability)
    set_paid, remnant = 0    
    p = {}    
    transaction = 0
    transaction = liability.amount_account_receivable.nil? ? liability.transaction_value  : liability.amount_account_receivable
    #total = params[:liability][:payed_value].blank? ?  paid.payed_value.to_f : paid.payed_value.to_f + params[:liability][:payed_value].to_f
    set_paid = params[:liability][:payed_value].blank? ? paid.payed_value.to_f : paid.payed_value.to_f + params[:liability][:payed_value].to_f
    remnant = params[:liability][:payed_value].blank? ? transaction : paid.last_value -  params[:liability][:payed_value].to_f
    if remnant == 0
      stat = "2"
      liability.update_attribute(:status_id, stat)
    end
    p = {:last_value => remnant, :payed_value => set_paid, :vendor_customer_id => liability.vendor_id}
    p = p.merge(params[:paid]) if params[:paid]
    return p    
  end

  private
  def initial_method
    @title = "DAFTAR UTANG JATUH TEMPO"
    @periode = true
  end	
end
