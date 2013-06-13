class Accounting::ReceivableMaturitiesController < ApplicationController
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
    conditions << "MONTH(#{$type})=#{$month}"
    conditions << "YEAR(#{$type})=#{$year}"
    conditions << "amount_account_payable > 0"
    conditions = conditions.join(" AND ")

    @receivables = AccountingSaleBalance.find(:all, :conditions => conditions)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @receivables }
      format.pdf  {
        send_data render_to_pdf({
            :action => 'index.rpdf',
            :page => 'portrait',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename => "piutang_jatuh_tempo_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "piutang_jatuh_tempo_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end 
  end

  def edit
    @receivable = Receivable.find(params[:id])
    @sale = @receivable.sale
    ppn_keluaran = AccountingTax.find_by_account_type('ppn_keluaran')
    @ppn_keluaran_rate_value = ppn_keluaran.nil? ? 0 : ppn_keluaran.rate_value
    @ppn = @receivable.manual_journal.values.find_by_account_id(ppn_keluaran.account_id)
    render :layout => false
  end

  def show_for_print
    @receivable = Receivable.find(params[:id])
    @sale = @receivable.sale
    @index = params[:index]
    render :layout => "print_layout"
  end

  def update
    @receivable = Receivable.find(params[:id])
    @receivable.created_at = params[:receivable_updated_at]
   
    @receivable.manual_journal.update_attributes(
      :evidence => params[:receivable][:evidence],
      :created_at => params[:receivable_updated_at]
    )

    sale = @receivable.sale
    journal_value = sale.currency.name.downcase == "rupiah" ? params[:receivable][:payed_value] : params[:receivable][:payed_value].to_i * sale.kurs
    ppn_keluaran = AccountingTax.find_by_account_type('ppn_keluaran')
    ppn = @receivable.manual_journal.values.find_by_account_id(ppn_keluaran.account_id)
    @receivable.manual_journal.values.each do |value|
      if !ppn.nil?
      account_id = value.is_debit ? AccountingSaleDebitCredit.find(params[:transfer][:sale_debit_credit_id]).account_id : value.account_id == ppn.account_id ? ppn.account_id : AccountingSaleDebitCredit.find_by_account_type('receivable').account_id
      else
         account_id = value.is_debit ? AccountingSaleDebitCredit.find(params[:transfer][:sale_debit_credit_id]).account_id : AccountingSaleDebitCredit.find_by_account_type('receivable').account_id
      end
        value.update_attributes(:value =>  journal_value,:account_id => account_id )
    end

    sale_attributes = {}
    if params[:receivable][:payed_value].to_f > @receivable.payed_value.to_f
      diff = (params[:receivable][:payed_value].to_f - params[:ppn][:value].to_f )- @receivable.payed_value.to_f
      sale_attributes[:amount_account_payable] = sale.amount_account_payable - diff
      sale_attributes[:paid] = sale.paid + diff
    elsif params[:receivable][:payed_value].to_f < @receivable.payed_value.to_f
      diff = @receivable.payed_value.to_f - (params[:receivable][:payed_value].to_f - params[:ppn][:value].to_f)
      sale_attributes[:amount_account_payable] = sale.amount_account_payable + diff
      sale_attributes[:paid] = sale.paid - diff
    end

    $selected_month, $selected_year = @receivable.updated_at.strftime("%m"), @receivable.updated_at.strftime("%Y")
    
    respond_to do |format|
      if @receivable.update_attributes(params[:receivable]) & sale.update_attributes(sale_attributes)
        flash[:notice] = 'Piutang Jatuh Tempo berhasil di update'
        format.xml  { head :ok }
      else
        flash[:error] = 'Piutang Jatuh Tempo gagal di update'
        format.xml  { render :xml => @receivable.errors, :status => :unprocessable_entity }
      end

      case params[:from]
      when 'm'
        format.html { redirect_to(accounting_receivable_maturities_path) }
      when 's'
        format.html { redirect_to(accounting_sale_balances_path) }
      end
    end
  end
  
  def do_pay
    receivable = AccountingSaleBalance.find(params[:id])
    render :update do |page|
      page.replace_html "target", :partial => "do_pay", :locals => {:receivable => receivable}
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

  def make_parameter_sales(paid, liability)
    set_paid, remnant = 0
    p = {}    
    set_paid = params[:total].blank? ? paid.payed_value.to_f : paid.payed_value.to_f + params[:total].to_f
    remnant = params[:total].blank? ? (liability.amount_account_payable.nil? ? liability.transaction_value : liability.amount_account_payable) : paid.last_value -  params[:total].to_f    
    if remnant == 0
      stat = "2"
      liability.update_attribute(:status_id, stat)
    end
    p = {:last_value => remnant, :payed_value => set_paid, :vendor_customer_id => liability.customer_id}
    p = p.merge(params[:paid]) if params[:paid]
    return p
  end
  
  private
  
  def initial_method
    @title = "DAFTAR PIUTANG JATUH TEMPO"
    @periode = true
  end		
end
