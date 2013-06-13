class Accounting::SaleBalancesController < ApplicationController
  before_filter :login_required, :initial_method
  skip_before_filter :verify_authenticity_token, :only => [
    :auto_complete_for_customer_code,
    :multi_auto_complete_for_accounting_sale_balance_detail_product_name,
    :multi_auto_complete_for_detail_service_name,:edit_after_transfer, :transfer_all]

  def index
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

    @can_input = true
    @can_input = false if AccountingSaleSignature.all.empty?
    @can_input = false if AccountingSaleDebitCredit.find_by_account_type('cash').nil?
    @can_input = false if AccountingSaleDebitCredit.find_by_account_type('receivable').nil?
    @can_input = false if AccountingSaleDebitCredit.find_by_account_type('sale').nil?
    @can_input = false if AccountingSaleDebitCredit.find_by_account_type('shipping').nil?
    @can_input = false if AccountingSaleDebitCredit.find_by_account_type('shipping_contra').nil?
    @can_input = false if AccountingSaleDebitCredit.find_by_account_type('discount').nil?

    conditions = []
    conditions << "MONTH(invoice_date)=#{$month}"
    conditions << "YEAR(invoice_date)=#{$year}"
    conditions = conditions.join(" AND ")

    @sale_balances = AccountingSaleBalance.paginate :page => params[:page], :conditions => conditions, :order => 'invoice_date DESC, id DESC'
    respond_to do |format|
      format.html
      format.xml  { render :xml => @accounting_sale_balances }
      format.pdf  {
        send_data render_to_pdf({
            :action => 'index.rpdf',
            :page => 'landscape',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename => "penjualan_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "penjualan_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end
  end

  def show
    @sale_balance = AccountingSaleBalance.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @sale_balance }
    end
  end

  def show_for_print
    @sale_balance = AccountingSaleBalance.find(params[:id])
    render :layout => "print_layout"
  end

  def show_for_print_pajak
    @sale_balance = AccountingSaleBalance.find(params[:id])
    ppn_keluaran = AccountingTax.find_by_account_type('ppn_keluaran')
    @ppn_keluaran_rate_value = ppn_keluaran.nil? ? 0 : ppn_keluaran.rate_value
    render :layout => "print_pajak"
  end

  def new
    @index = -1
    @index_service = -1
    @sale_balance = AccountingSaleBalance.new
    ppn_keluaran = AccountingTax.find_by_account_type('ppn_keluaran')
    @ppn_keluaran_rate_value = ppn_keluaran.nil? ? 0 : ppn_keluaran.rate_value
    render :layout => false
  end

  def sale_help
    render :layout => false
  end

  def edit
    @sale_balance = AccountingSaleBalance.find(params[:id])
    @index = @sale_balance.accounting_sale_balance_details.size
    @index_service = @sale_balance.service_details.size
    ppn_keluaran = AccountingTax.find_by_account_type('ppn_keluaran')
    @ppn_keluaran_rate_value = ppn_keluaran.nil? ? 0 : ppn_keluaran.rate_value
    render :layout => false
  end

  def filter
    conditions = []
    conditions << "MONTH(invoice_date) = #{params[:date][:month]}"
    conditions << "YEAR(invoice_date) = #{params[:date][:year]}"
    conditions = conditions.join(" AND ")
    $date_un =params[:date][:month]
    $year_un =params[:date][:year]
    @credit = AccountingSaleDebitCredit.count(:all, :conditions => ["credit IS true"])
    @debit = AccountingSaleDebitCredit.count(:all, :conditions => ["debit IS true"])
    @sale_balances = AccountingSaleBalance.find(:all, :conditions => conditions)
    render :action => :index
  end

  def create
    maturity_date = params[:sale_balance_maturity_date].split("-")
    params[:sale_balance]["maturity_date(1i)"] = maturity_date[2]
    params[:sale_balance]["maturity_date(2i)"] = maturity_date[1]
    params[:sale_balance]["maturity_date(3i)"] = maturity_date[0]
    invoice_date = params[:sale_balance_invoice_date].split("-")
    params[:sale_balance]["invoice_date(1i)"] = invoice_date[2]
    params[:sale_balance]["invoice_date(2i)"] = invoice_date[1]
    params[:sale_balance]["invoice_date(3i)"] = invoice_date[0]

    @sale_balance = AccountingSaleBalance.new(params[:sale_balance])
    @sale_balance.created_at = params[:sale_balance_invoice_date]
    @sale_balance.shipping_date = params[:sale_balance_shipping_date]

    
    ## detail barang
    loop = params[:count].nil? ? 0 : params[:count].to_i
    loop = 0 if params[:count].to_i < 0
    0.upto(loop) do |i|
      detail = AccountingSaleBalanceDetail.new
      if params["accounting_sale_balance_detail_product_id_#{i}"] != nil
        detail.product_name =  params["accounting_sale_balance_detail_product_name_#{i}"]
        detail.qty = params["accounting_sale_balance_detail_qty_#{i}"]
        detail.price = params["accounting_sale_balance_detail_price_#{i}"]
        detail.subtotal = params["accounting_sale_balance_detail_subtotal_#{i}"]
        detail.item_id = params["accounting_sale_balance_detail_product_id_#{i}"].to_s
        @sale_balance.accounting_sale_balance_details << detail
      end
    end

    ## detail servis
    loop = params[:count_service].nil? ? 0 : params[:count_service].to_i
    loop = 0 if params[:count_service].to_i < 0
    0.upto(loop) do |i|
      service_detail = AccountingSaleBalanceServiceDetail.new
      if params["detail_service_id_#{i}"] != nil
        service_detail.qty = params["detail_service_qty_#{i}"]
        service_detail.price = params["detail_service_price_#{i}"]
        service_detail.subtotal = params["detail_service_subtotal_#{i}"]
        service_detail.service_id = params["detail_service_id_#{i}"].to_s
        @sale_balance.service_details << service_detail
      end
    end

    $selected_month , $selected_year = @sale_balance.invoice_date.strftime("%m") , @sale_balance.invoice_date.strftime("%Y")

    @sale_balance.create_journal
    @sale_balance.create_manual_journal
    @sale_balance.paid = @sale_balance.payment_value - @sale_balance.ppn_value
    @sale_balance.payment_value -= @sale_balance.ppn_value
    @sale_balance.amount_account_payable = @sale_balance.transaction_value - @sale_balance.paid

    respond_to do |format|
      if @sale_balance.save
        status = TransItemStatus.find_or_create_by_name(params[:customer][:code])
        0.upto(loop) do |i|
          if params[:sale_balance][:sent]=="true"
            item = Item.find(params["accounting_sale_balance_detail_product_id_#{i}"])
            item_details = item.item_details.find(:all, :conditions => ["item_id = '#{item.id}' AND qty != 0"], :order => "sequence ASC")
            qty = params["accounting_sale_balance_detail_qty_#{i}"].to_i
            item_details.each do |item_detail|
              break if qty <= 0
              tmp = item_detail.qty > qty ? item_detail.qty - qty : 0
              qty -= item_detail.qty
              TransItem.create(:user_id => current_user.id, :item_id => params["accounting_sale_balance_detail_product_id_#{i}"], :is_addition => false,
                :price => item_detail.price,:qty => (item_detail.qty - tmp), :status => status.id,:purchase_sale_id => @sale_balance.id, :description => "Penjualan" )
              item_detail.update_attributes(:qty => tmp, :total => (tmp * item_detail.price.to_f) )
            end
            Item.sum_qty_and_total(item.id)
          end if params["accounting_sale_balance_detail_product_id_#{i}"] != nil
        end
        flash[:notice] = 'Transaksi Penjualan berhasil disimpan'
        format.html { redirect_to(accounting_sale_balances_path) }
        format.xml  { render :xml => @sale_balance, :status => :created, :location => @sale_balance }
      else
        flash[:notice] = 'Transaksi Penjualan gagal disimpan'
        format.html { render :action => "new" }
        format.xml  { render :xml => @sale_balance.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    maturity_date = params[:sale_balance_maturity_date].split("-")
    params[:sale_balance]["maturity_date(1i)"] = maturity_date[2]
    params[:sale_balance]["maturity_date(2i)"] = maturity_date[1]
    params[:sale_balance]["maturity_date(3i)"] = maturity_date[0]
    invoice_date = params[:sale_balance_invoice_date].split("-")
    params[:sale_balance]["invoice_date(1i)"] = invoice_date[2]
    params[:sale_balance]["invoice_date(2i)"] = invoice_date[1]
    params[:sale_balance]["invoice_date(3i)"] = invoice_date[0]

    @sale_balance = AccountingSaleBalance.find(params[:id])
    @sale_balance.created_at = params[:sale_balance_invoice_date]
    @sale_balance.shipping_date = params[:sale_balance_shipping_date]
    @sale_balance.shipping_cost = params[:sale_balance][:shipping_cost]

    #    params[:sale_balance][:payment_value] = params[:sale_balance][:payment_value].to_f - params[:sale_balance][:ppn_value].to_f
    @sale_balance.payment_value = params[:sale_balance][:payment_value]
    @sale_balance.transaction_value = params[:sale_balance][:transaction_value]
    @sale_balance.discount = params[:sale_balance][:discount]
    @sale_balance.subtotal = params[:sale_balance][:subtotal]
    @sale_balance.ppn_value = params[:sale_balance][:ppn_value]
    @sale_balance.paid = params[:sale_balance][:payment_value]
    @sale_balance.currency_id = params[:sale_balance][:currency_id]
    @sale_balance.kurs = params[:sale_balance][:kurs]
    @sale_balance.amount_account_payable = @sale_balance.transaction_value - @sale_balance.paid

    ## detail item
    @sale_balance.accounting_sale_balance_details.each { |detail| detail.destroy }

    loop = params[:count].nil? ? 0 : params[:count].to_i
    loop = 0 if params[:count].to_i < 0
    0.upto(loop) do |i|
      detail = AccountingSaleBalanceDetail.new
      if params["accounting_sale_balance_detail_product_id_#{i}"] != nil
        detail.product_name =  params["accounting_sale_balance_detail_product_name_#{i}"]
        detail.qty = params["accounting_sale_balance_detail_qty_#{i}"]
        detail.price = params["accounting_sale_balance_detail_price_#{i}"]
        detail.subtotal = params["accounting_sale_balance_detail_subtotal_#{i}"]
        detail.item_id = params["accounting_sale_balance_detail_product_id_#{i}"].to_s
        if params[:sale_balance][:sent]=="true"
          item = Item.find(params["accounting_sale_balance_detail_product_id_#{i}"])
          item_details = item.item_details.find(:all, :conditions => ["item_id = '#{item.id}' AND qty != 0"], :order => "sequence ASC")
          qty = params["accounting_sale_balance_detail_qty_#{i}"].to_i
          item_details.each do |item_detail|
            break if qty <= 0
            tmp = item_detail.qty > qty ? item_detail.qty - qty : 0
            qty -= item_detail.qty
            TransItem.create(:user_id => current_user.id, :item_id => params["accounting_sale_balance_detail_product_id_#{i}"], :is_addition => false,
              :price => item_detail.price,:qty => (item_detail.qty - tmp), :status => status.id,:purchase_sale_id => @sale_balance.id, :description => "Penjualan" )
            item_detail.update_attributes(:qty => tmp, :total => (tmp * item_detail.price.to_f) )
          end
          Item.sum_qty_and_total(item.id)
        end if @sale_balance.sent == false
        @sale_balance.accounting_sale_balance_details << detail
      end
    end

    ## detail service
    @sale_balance.service_details.each { |detail| detail.destroy }
    loop = params[:count_service].nil? ? 0 : params[:count_service].to_i
    loop = 0 if params[:count_service].to_i < 0
    0.upto(loop) do |i|
      service_detail = AccountingSaleBalanceServiceDetail.new
      if params["detail_service_id_#{i}"] != nil
        service_detail.qty = params["detail_service_qty_#{i}"]
        service_detail.price = params["detail_service_price_#{i}"]
        service_detail.subtotal = params["detail_service_subtotal_#{i}"]
        service_detail.service_id = params["detail_service_id_#{i}"].to_s
        @sale_balance.service_details << service_detail
      end
    end

    $selected_month , $selected_year = @sale_balance.invoice_date.strftime("%m") , @sale_balance.invoice_date.strftime("%Y")
    @sale_balance.delete_values
    @sale_balance.create_journal
    @sale_balance.create_manual_journal
    
    params[:sale_balance][:payment_value] = params[:sale_balance][:payment_value].to_f - params[:sale_balance][:ppn_value].to_f

    respond_to do |format|
      if @sale_balance.update_attributes(params[:sale_balance])
        flash[:notice] = 'Transaksi Penjualan berhasil diupdate'
        if params[:with_print]=="true"
          session[:sale_balance_print] = true
          session[:sale_balance_id] = @sale_balance.id
        end
        format.html { redirect_to(accounting_sale_balances_path) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Transaksi Penjualan gagal diupdate'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sale_balance.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @sale_balance = AccountingSaleBalance.find(params[:id])
    $selected_month , $selected_year = @sale_balance.invoice_date.strftime("%m") , @sale_balance.invoice_date.strftime("%Y")
    if @sale_balance.destroy
      flash[:notice] = 'Transaksi Penjualan berhasil dihapus.'
    else
      flash[:notice] = 'Transaksi Penjualan gagal dihapus.'
    end

    respond_to do |format|
      format.html { redirect_to(accounting_sale_balances_url) }
      format.xml  { head :ok }
    end
  end

  def add_barang
    render :update do |page|
      page.insert_html :before, "end_of_accounting_sale_balance_detail",
        :partial => 'accounting/sale_balances/accounting_sale_balance_detail',
        :object => AccountingSaleBalanceDetail.new,
        :locals => {:index => params[:index], :size => params[:size], :ppn_rate => params[:ppn_rate]}
      page.replace_html "link_add", :partial => "accounting/sale_balances/add_new_link", :locals => {:index => params[:index], :size => params[:size], :ppn_keluaran_rate_value => params[:ppn_rate]}
      page.call "setIndex", 1,'count'
    end
  end

  def add_service
    render :update do |page|
      page.insert_html :before, "end_of_accounting_sale_balance_service_detail",
        :partial => 'accounting/sale_balances/accounting_sale_balance_service_detail',
        :object => AccountingSaleBalanceServiceDetail.new,
        :locals => {:index => params[:index], :size => params[:size], :ppn_rate => params[:ppn_rate]}
      page.replace_html "link_service_add", :partial => "accounting/sale_balances/add_new_service_link", :locals => {:index => params[:index], :size => params[:size], :ppn_keluaran_rate_value => params[:ppn_rate]}
      page.call "setIndex", 1,'count_service'
    end
  end

  def prepare_show_currency
    @search = Currency.find(:all)
    search = params[:id].empty? ? nil : Currency.find(params[:id])
    render :update do |page|
      page.replace_html "show-kurs", :partial => "kurs", :locals => {:search => search, :value => 0}
      page.replace_html "kurs-text", search.name.downcase == "rupiah" ? "&nbsp;" : "Kurs"
    end
  end
  
  def auto_complete_for_customer_code
    search = params[:customer][:code]
    @customers = Customer.find(:all, :conditions => ["name LIKE ? ", "%#{search}%"])
    render :partial => "list_customer"
  end

  def multi_auto_complete_for_accounting_sale_balance_detail_product_name
    search = params["accounting_sale_balance_detail_product_name_#{params[:index]}"]
    products = Item.find(:all, :conditions => ["name LIKE ? AND stock > '0'", "%#{search}%"])
    render :partial => "shared/autocomplete_product", :locals => {:products => products}
  end

  def multi_auto_complete_for_detail_service_name
    search = params["detail_service_name_#{params[:index]}"]
    services = Service.find(:all, :conditions => ["name LIKE ?", "%#{search}%"])
    render :partial => "shared/autocomplete_service", :locals => {:services => services}
  end

  def change_print_content
    render :update do |page|
      page.replace params[:id], :partial => "shared/change_print_content", :locals => {:id => params[:id], :content => params[:content]}
    end
  end

  def update_print_content
    render :update do |page|
      page.replace params[:id], :partial => "shared/updatable_print_content", :locals => {:id => params[:id], :content => params[:content]}
    end
  end

  def payment_record
    render :update do |page|
      if params[:show]
        page.replace_html "payment-record-#{params[:id]}", :partial => "payment_record", :locals => {:sale => AccountingSaleBalance.find(params[:id]) }
      else
        page.replace_html "payment-record-#{params[:id]}", ""
      end
      page.replace_html "show-hide-payment-record-#{params[:id]}", :partial => "payment_record_trigger", :locals => {:sale => AccountingSaleBalance.find(params[:id]), :show => !params[:show] }
    end
  end

  def do_payment
    @sale = AccountingSaleBalance.find(params[:id])
    @receivable = Receivable.new
    ppn_keluaran = AccountingTax.find_by_account_type('ppn_keluaran')
    @ppn_keluaran_rate_value = ppn_keluaran.nil? ? 0 : ppn_keluaran.rate_value
    render :layout => false
  end

  def create_payment
    sale = AccountingSaleBalance.find(params[:sale_balance_id])

    @receivable = Receivable.new(params[:receivable])
    @receivable.created_at = params[:receivable_updated_at]
    @receivable.payed_value =  @receivable.payed_value.to_f - params[:ppn][:value].to_f
    @receivable.last_value = sale.amount_account_payable - @receivable.payed_value.to_f
    @receivable.vendor_customer_id = sale.customer_id
    @receivable.sale = sale
    sale_attributes = {}
    sale_attributes[:amount_account_payable] = sale.amount_account_payable - ( params[:receivable][:payed_value].to_i - params[:ppn][:value].to_f)
    sale_attributes[:paid] = sale.paid + (params[:receivable][:payed_value].to_f - params[:ppn][:value].to_f )

    manual_journal = AccountingManualJournal.new
    manual_journal.created_at = params[:receivable_updated_at]
    manual_journal.evidence = params[:receivable][:evidence]
    manual_journal.editable = false

    journal_value = sale.currency.name.downcase == "rupiah" ? params[:receivable][:payed_value] : params[:receivable][:payed_value].to_i * sale.kurs
    debit_journal = AccountingJournalValue.new(
      :account_id => AccountingSaleDebitCredit.find(params[:transfer][:sale_debit_credit_id]).account_id,
      :value => journal_value,
      :is_debit => true
    )
    manual_journal.values << debit_journal

    credit_journal = AccountingJournalValue.new(
      :account_id => AccountingSaleDebitCredit.find_by_account_type('receivable').account_id,
      :value => journal_value.to_f - params[:ppn][:value].to_f,
      :is_debit => false
    )
    manual_journal.values << credit_journal

    ppn = sale.currency.name.downcase == "rupiah" ? params[:ppn][:value] : params[:ppn][:value] * sale.kurs
    credit_journal = AccountingJournalValue.new(
      :account_id => AccountingSaleDebitCredit.find_by_account_type('ppn_keluaran').account_id,
      :value => ppn,
      :is_debit => false
    ) if ppn != "0"
     
    manual_journal.values << credit_journal

    @receivable.manual_journal = manual_journal

    $selected_month, $selected_year = sale.created_at.strftime("%m"), sale.created_at.strftime("%Y")
    
    respond_to do |format|
      if sale.update_attributes(sale_attributes) && @receivable.save
        flash[:notice] = 'Pembayaran piutang berhasil disimpan'
        format.xml  { head :ok }
      else
        flash[:error] = 'Pembayaran piutang gagal disimpan'
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

  def edit_after_transfer
    accounts =   AccountingSaleDebitCredit.find(:all, :conditions => ["account_type = 'cash'OR account_type = 'Bank'  AND debit = '1'"])
    accounts.each  { |account| transfer_tmp = AccountingSaleBalance.find(params[:id]).values.find_by_sale_debit_credit_id(account.id)
      @transfer = transfer_tmp if !transfer_tmp.nil?
    }
    render :layout => false
  end

  def update_account_trasnfer
    account =  AccountingSaleDebitCredit.find(params[:transfer][:sale_debit_credit_id])
    transfer =  AccountingSaleDebitCreditValue.find(params[:id])
    params[:transfer][:transfer_date] = params[:transfer_updated_at]
    params[:transfer][:account_id] = account.account_id
    respond_to do |format|
      if transfer.update_attributes(params[:transfer])
        flash[:notice] = 'Transfer berhasil disimpan'
        format.html { redirect_to(accounting_sale_balances_path) }
        format.xml  { head :ok }
      else
        flash[:error] = 'Transfer gagal disimpan'
        format.html { redirect_to(accounting_sale_balances_path) }
        format.xml  { render :xml => transfer.errors, :status => :unprocessable_entity }
      end
    end
  end

  def transfer_all
    $selected_account, $piutang  = [],[]
    if params[:id]
      @receivables = Receivable.all
    else
      @sale_balances = AccountingSaleBalance.all
    end
    render :layout => false
  end

  def save_transfer_all
    accounts =   AccountingSaleDebitCredit.find(:all, :conditions => ["account_type = 'cash' or  account_type = 'shipping' AND debit = '1'"])
    $selected_account.each do |sale|
      accounts.each  {
        |account| transfer = AccountingSaleBalance.find(sale).values.find_by_sale_debit_credit_id(account.id)
        account_id = ''
        debitcredit = account.account_type == "cash" ? AccountingSaleDebitCredit.find(params[:account][:sale_debit_credit_id]) : AccountingSaleDebitCredit.find(:first, :conditions => ["account_type = 'shipping_bank' AND account_id ='#{ AccountingSaleDebitCredit.find(params[:account][:sale_debit_credit_id]).account_id}' "])
        params["transfer_#{transfer.id}"][:updated_at] = params[:paid_updated_at]
        params["transfer_#{transfer.id}"][:account_id] =  debitcredit.account_id
        params["transfer_#{transfer.id}"][:sale_balance_id] = sale
        params["transfer_#{transfer.id}"][:sale_debit_credit_id] =  debitcredit.id
        transfer.update_attributes(params["transfer_#{transfer.id}"]) if params["check_#{sale}"]
      }
    end if !$selected_account.nil?
    $piutang.each do |id|
      if !params["id_#{id}"].nil?
        receivable = Receivable.find(id)
        value = receivable.manual_journal.values.find(params["id_#{id}"])
        params["transfer_#{id}"][:updated_at] = params[:paid_updated_at]
        params["transfer_#{id}"][:account_id] = AccountingSaleDebitCredit.find(params[:account][:sale_debit_credit_id]).account_id
        value.update_attributes(params["transfer_#{id}"]) if params["check_#{id}"]
      end
    end if !$piutang.nil?

    respond_to do |format|
      format.html { redirect_to(accounting_sale_balances_url) }
      format.xml  { head :ok }
    end
  end

  private

  def initial_method
    @title = "DAFTAR TRANSAKSI PENJUALAN"
    @periode = true
  end
end
