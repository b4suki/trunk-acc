class Accounting::PurchaseBalancesController < ApplicationController
  before_filter :login_required, :initial_method
  skip_before_filter :verify_authenticity_token, :only => [
    :auto_complete_for_item_name, :auto_complete_for_vendor_name,
    :auto_complete_for_account_code, :auto_complete_for_contra_account_code,
    :auto_complete, :multi_auto_complete_for_accounting_purchase_balance_detail_product_name]
  
  def index
    @credit = AccountingPurchaseDebitCredit.count(:all, :conditions => ["credit IS true"], :group => "account_id").length
    @debit = AccountingPurchaseDebitCredit.count(:all, :conditions => ["debit IS true"], :group => "account_id").length
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
    @can_input = false if AccountingPurchaseDebitCredit.find_by_account_type('purchase').nil?
    @can_input = false if AccountingPurchaseDebitCredit.find_by_account_type('cash').nil?
    @can_input = false if AccountingPurchaseDebitCredit.find_by_account_type('payable').nil?
    @can_input = false if AccountingPurchaseDebitCredit.find_by_account_type('discount').nil?
    @can_input = false if AccountingPurchaseDebitCredit.find_by_account_type('shipping_debit').nil?
    @can_input = false if AccountingPurchaseDebitCredit.find_by_account_type('shipping_credit').nil?

    conditions = []
    conditions << "MONTH(invoice_date) = #{$month}"
    conditions << "YEAR(invoice_date) = #{$year}"
    conditions = conditions.join(" AND ")
    
    @purchase_balances = AccountingPurchaseBalance.paginate :page => params[:page], :conditions => conditions, :order => 'invoice_date desc'
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounting_purchase_balances }
      format.pdf  { 
        send_data render_to_pdf({
            :action => 'index.rpdf', 
            :page => 'landscape',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename => "pembelian_#{selected_month.downcase}_#{selected_year.downcase}.pdf" 
      }
      format.xls { render_to_xls(:filename => "pembelian_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end    
  end

  def show
    @purchase_balance = AccountingPurchaseBalance.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @purchase_balance }
    end
  end

  def show_for_print
    @purchase_balance = AccountingPurchaseBalance.find(params[:id])
    render :layout => "print_layout"
  end
  
  def new
    @count = -1
    @index = -1
    @purchase_balance = AccountingPurchaseBalance.new
    ppn_masukan = AccountingTax.find_by_account_type('ppn_masukan')
    @ppn_masukan_rate_value = ppn_masukan.nil? ? 0 : ppn_masukan.rate_value
    render :layout => false    
  end
   
  def edit
    @index = -1        
    @purchase_balance = AccountingPurchaseBalance.find(params[:id])
    @count = @purchase_balance.accounting_purchase_balance_details.count
    @purchase_balance_details = AccountingPurchaseBalance.find_all_by_invoice_number(params[:id])
    @purchase_balance_values = AccountingPurchaseDebitCreditValue.find_all_by_group_id(params[:id])
    ppn_masukan = AccountingTax.find_by_account_type('ppn_masukan')
    @ppn_masukan_rate_value = ppn_masukan.nil? ? 0 : ppn_masukan.rate_value
    render :layout => false
  end

  def create     
    invoice_date = params[:purchase_balance_invoice_date].split("-")
    params[:purchase_balance]["invoice_date(1i)"] = invoice_date[2]
    params[:purchase_balance]["invoice_date(2i)"] = invoice_date[1]
    params[:purchase_balance]["invoice_date(3i)"] = invoice_date[0]        
    #    params[:purchase_balance][:terms_of_payment_id] = get_id_payment(params[:terms_of_payment][:id])
    maturity_date = params[:purchase_balance_maturity_date].split("-")
    params[:purchase_balance]["maturity_date(1i)"] = maturity_date[2]
    params[:purchase_balance]["maturity_date(2i)"] = maturity_date[1]
    params[:purchase_balance]["maturity_date(3i)"] = maturity_date[0]

    #    id_payment = get_id_payment(params[:terms_of_payment][:id])
    
    @purchase_balance = AccountingPurchaseBalance.new(params[:purchase_balance])
    @purchase_balance.created_at = params[:purchase_balance_invoice_date]
    @purchase_balance.paid = params[:purchase_balance][:payment_value]
    @purchase_balance.terms_of_payment_id = get_id_payment(params["terms_of_payment"][:id])
    #    @purchase_balance.terms_of_payment_id = id_payment

    loop = params[:count].nil? ? 0 : params[:count].to_i
    loop = 0 if loop < 0

    0.upto(loop) do |x|
      if params["accounting_purchase_balance_detail_product_name_#{x}"].to_s != nil && params["accounting_purchase_balance_detail_product_name_#{x}"] != nil
        obj = AccountingPurchaseBalanceDetail.new(
          :product_name => params["accounting_purchase_balance_detail_product_name_#{x}"],
          :price => params["accounting_purchase_balance_detail_price_#{x}"],
          :qty => params["accounting_purchase_balance_detail_qty_#{x}"],
          :disc_percentage => params["purchase_balance_disc_percentage_#{x}"],
          :discount => params["purchase_balance_discount_#{x}"],
          :item_id => params["accounting_purchase_balance_detail_item_id_#{x}"],
          :subtotal => params["accounting_purchase_balance_detail_subtotal_#{x}"])

        if params[:purchase_balance][:received]=="true"
          item = Item.find(obj.item_id)
          currency = Currency.find(params[:purchase_balance][:currency_id])
          price = currency.name.downcase == "rupiah" ? obj.price : obj.price.to_f * params[:purchase_balance][:kurs].to_f
          @purchase_balance.item_details<< ItemDetail.create(
            :item_id => obj.item_id,
            :qty => obj.qty,
            :price => price,
            :total => obj.qty * price,
            :is_deleted => false,
            :purchasing_date => params[:purchase_balance_invoice_date]
          )
          item.recalculate_stock_from_item_details(item, 0)
        end

        @purchase_balance.accounting_purchase_balance_details << obj
      end
    end

    @purchase_balance.create_journal

    $selected_month, $selected_year = params[:purchase_balance_invoice_date].to_date.strftime("%m"), params[:purchase_balance_invoice_date].to_date.strftime("%Y")
    
    respond_to do |format|
      if @purchase_balance.save
        tran_status = TransItemStatus.find_by_name(params[:vendor][:name])
        tran_status = TransItemStatus.create(:name => params[:vendor][:name]) if tran_status.nil?
        0.upto(loop) do |x|
          if params[:purchase_balance][:received]=="true"
            item = Item.find(params["accounting_purchase_balance_detail_item_id_#{x}"])
            currency = Currency.find(params[:purchase_balance][:currency_id])
            price = currency.name.downcase == "rupiah" ? params["accounting_purchase_balance_detail_price_#{x}"] : params["accounting_purchase_balance_detail_price_#{x}"].to_f * params[:purchase_balance][:kurs].to_f
            TransItem.create(
              :user_id => current_user.id,
              :item_id => params["accounting_purchase_balance_detail_item_id_#{x}"],
              :qty => params["accounting_purchase_balance_detail_qty_#{x}"],
              :price => price,
              :is_addition => true,
              :status => tran_status.id,
              :purchase_sale_id => @purchase_balance.id,
              :description => "Pembelian")
          end if params["accounting_purchase_balance_detail_product_name_#{x}"].to_s != nil && params["accounting_purchase_balance_detail_product_name_#{x}"] != nil
        end
       

        flash[:notice] = 'Transaksi Pembelian berhasil dibuat.'
        if params[:show_print]=="true"
          session[:purchase_balance_print] = true
          session[:purchase_balance_invoice_no] = params[:purchase_balance][:invoice_number]
        end
        format.html { redirect_to(accounting_purchase_balances_path) }
        format.xml  { render :xml => @purchase_balance, :status => :created, :location => @purchase_balance }
      else
        flash[:notice] = 'Transaksi Pembelian gagal dibuat.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @purchase_balance.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    invoice_date = params[:purchase_balance_invoice_date].split("-")
    params[:purchase_balance]["invoice_date(1i)"] = invoice_date[2]
    params[:purchase_balance]["invoice_date(2i)"] = invoice_date[1]
    params[:purchase_balance]["invoice_date(3i)"] = invoice_date[0]
    maturity_date = params[:purchase_balance_maturity_date].split("-")
    params[:purchase_balance]["maturity_date(1i)"] = maturity_date[2]
    params[:purchase_balance]["maturity_date(2i)"] = maturity_date[1]
    params[:purchase_balance]["maturity_date(3i)"] = maturity_date[0]

    @purchase_balance = AccountingPurchaseBalance.find(params[:id])
    @purchase_balance.accounting_purchase_balance_details.each do |detail|
      detail.destroy
    end
    trans = TransItem.find_all_by_description_and_purchase_sale_id("Pembelian",@purchase_balance.id)
    trans.each { |tran| tran.destroy  }
    tran_status = TransItemStatus.find_by_name(params[:vendor][:name])
    tran_status = TransItemStatus.create(:name => params[:vendor][:name]) if tran_status.nil?
    @purchase_balance.item_details.each do |item_detail|
      item = item_detail.item
      item_detail.destroy
      item.recalculate_stock_from_item_details(item, 0)
    end
    loop = params[:count].nil? ? 0 : params[:count].to_i
    loop = 0 if loop < 0

    0.upto(loop) do |x|
      if params["accounting_purchase_balance_detail_product_name_#{x}"].to_s != nil && params["accounting_purchase_balance_detail_product_name_#{x}"] != nil
        obj = AccountingPurchaseBalanceDetail.new(
          :product_name => params["accounting_purchase_balance_detail_product_name_#{x}"],
          :price => params["accounting_purchase_balance_detail_price_#{x}"],
          :qty => params["accounting_purchase_balance_detail_qty_#{x}"],
          :disc_percentage => params["purchase_balance_disc_percentage_#{x}"],
          :discount => params["purchase_balance_discount_#{x}"],
          :item_id => params["accounting_purchase_balance_detail_item_id_#{x}"],
          :subtotal => params["accounting_purchase_balance_detail_subtotal_#{x}"])

        if params[:purchase_balance][:received]=="true"
          item = Item.find(obj.item_id)
          currency = Currency.find(params[:purchase_balance][:currency_id])
          price = currency.name.downcase == "rupiah" ? obj.price : obj.price.to_f * params[:purchase_balance][:kurs].to_f
          @purchase_balance.item_details << ItemDetail.create(
            :item_id => obj.item_id,
            :qty => obj.qty,
            :price => price,
            :total => obj.qty * price,
            :is_deleted => false,
            :purchasing_date => params[:purchase_balance_invoice_date]
          )
          item.recalculate_stock_from_item_details(item, 0)
          TransItem.create(
            :user_id => current_user.id,
            :item_id => obj.item_id,
            :qty => obj.qty,
            :price => price,
            :is_addition => true,
            :status => tran_status.id,
            :purchase_sale_id => @purchase_balance.id,
            :description => "Pembelian")
        end

        @purchase_balance.accounting_purchase_balance_details << obj
      end
    end

    @purchase_balance.subtotal = params[:purchase_balance][:subtotal]
    @purchase_balance.ppn_value = params[:purchase_balance][:ppn_value]
    @purchase_balance.payment_value = params[:purchase_balance][:payment_value]
    @purchase_balance.discount = params[:purchase_balance][:discount]
    @purchase_balance.transaction_value = params[:purchase_balance][:transaction_value]
    @purchase_balance.shipping_cost = params[:purchase_balance][:shipping_cost]
    @purchase_balance.currency_id = params[:purchase_balance][:currency_id]
    @purchase_balance.kurs = params[:purchase_balance][:kurs]
    @purchase_balance.terms_of_payment_id = get_id_payment(params["terms_of_payment"][:id])

    @purchase_balance.delete_values
    @purchase_balance.create_journal

    $selected_month, $selected_year = params[:purchase_balance_invoice_date].to_date.strftime("%m"), params[:purchase_balance_invoice_date].to_date.strftime("%Y")
    
    respond_to do |format|
      if @purchase_balance.update_attributes(params[:purchase_balance])
        flash[:notice] = 'Transaksi Pembelian berhasil diupdate.'
        if params[:show_print]=="true"
          session[:purchase_balance_print] = true
          session[:purchase_balance_invoice_no] = params[:purchase_balance][:invoice_number]
        end
        format.html { redirect_to(accounting_purchase_balances_path) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Transaksi Pembelian gagal diupdate.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @purchase_balance.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def auto_complete_for_contra_account_code
    search = params[:contra_account][:code]
    @accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "contra_account_autocomplete"
  end
              
  def auto_complete_for_account_code
    search = params[:account][:code]
    @accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "autocomplete"
  end

  def auto_complete_for_item_name
    search = params[:item][:name]
    @products = Item.find(:all, :conditions => ["name LIKE ?", "%#{search}%"])
    render :partial => "autocomplete_product"
  end

  def auto_complete_for_vendor_name
    search = params[:vendor][:name]
    @vendors = Vendor.find(:all, :conditions => ["name LIKE ?", "%#{search}%"])
    render :partial => "autocomplete_vendor"
  end

  def multi_auto_complete_for_accounting_purchase_balance_detail_product_name
    search = params["accounting_purchase_balance_detail_product_name_#{params[:index]}"]
    @products = Item.find(:all, :conditions => ["name LIKE ?", "%#{search}%"])
    render :partial => "autocomplete_product"
  end
    
  def destroy
    @purchase_balance = AccountingPurchaseBalance.find(params[:id])
    $selected_month, $selected_year = @purchase_balance.invoice_date.strftime("%m"), @purchase_balance.invoice_date.strftime("%Y")
    if @purchase_balance.destroy
      flash[:notice] = 'Transaksi Pembelian berhasil dihapus.'
    else
      flash[:notice] = 'Transaksi Pembelian gagal dihapus.'
    end

    respond_to do |format|
      format.html { redirect_to(accounting_purchase_balances_url) }
      format.xml  { head :ok }
    end
  end
  
  def get_id_payment(days)
    if days != "0"
      value =AccountingTermsOfPayment.find(:first, :conditions => ["days =#{days}"]).id
    else
      value = "cash"
    end
    value
  end
  
  def add_barang
    render :update do |page|
      page.insert_html :before, "end-of-accounting-purchase-balance-detail",
        :partial => 'accounting/purchase_balances/accounting_purchase_balance_detail',
        :object => AccountingPurchaseBalanceDetail.new,
        :locals => {:index => params[:index], :size => params[:size],
        :index_debit => params[:index_debit],
        :index_credit => params[:index_credit],
        :ppn_rate => params[:ppn_rate]}
      page.replace_html "link_add", :partial => "accounting/purchase_balances/add_new_link",
        :locals => {:index => params[:index], :size => params[:size],
        :index_debit => params[:index_debit], :index_credit => params[:index_credit],
        :ppn_rate => params[:ppn_rate]
      }
      page.call "setIndex", 1,'count'
    end
  end
  
  
  def add_debit
    index_parent = 0
    index_parent = params[:index_parent].to_i
    render :update do |page|
      page.insert_html :before, "accounting_purchase_debit_credit_#{params[:index_parent]}",
        :partial => 'accounting/purchase_balances/accounting_purchase_debit_credit',
        :object => AccountingPurchaseDebitCreditValue.new,
        :locals => {:index => params[:index], :index_parent => params[:index_parent]}
      page.replace_html "link_debit_#{params[:index_parent]}", :partial => "accounting/purchase_balances/add_new_link_debit",
        :locals => {:index => params[:index], :index_parent => params[:index_parent]}
      page.call "setIndex", 1,"count_debit_#{index_parent}"
      page.call "setIndex", 1,"count_debit_edit_#{index_parent}"
    end
  end

  def add_credit
    index_parent = 0
    index_parent = params[:index_parent]
    render :update do |page|
      page.insert_html :before, "accounting_purchase_credit_#{params[:index_parent]}",
        :partial => 'accounting/purchase_balances/accounting_purchase_credit',
        :object => AccountingPurchaseDebitCreditValue.new,
        :locals => {:index => params[:index], :index_parent => params[:index_parent]}
      page.replace_html "link_credit_#{params[:index_parent]}", :partial => "accounting/purchase_balances/add_new_link_credit",
        :locals => {:index => params[:index], :index_parent => params[:index_parent]}
      page.call "setIndex", 1,"count_credit_#{index_parent}"
      page.call "setIndex", 1,"count_credit_edit_#{index_parent}"
    end
  end
  
  def autocomplete_redbox
    render :update do |page|
      page.insert_html :top, "RB_window", :partial => "autocomplete_redbox",
        :locals => {
        :index => params[:index],
        :f => params[:f],
        :contra => params[:contra].nil? ? false : true
      }
      page.call "setTopPositionRedBox", 'RB_window'
    end
  end

  def autocomplete_redbox_product
    render :update do |page|
      page.insert_html :top, "RB_window", :partial => "autocomplete_redbox_product",
        :locals => {
        :index => params[:index],
        :f => params[:f]
      }
      page.call "setTopPositionRedBox", 'RB_window'
    end
  end

  def purchase_help
    render :layout => false
  end
  
  def prepare_show_currency
    @search = Currency.find(:all)
    search = params[:id].empty? ? nil : Currency.find(params[:id])
    render :update do |page|
      page.replace_html "show-kurs", :partial => "kurs", :locals => {:search => search, :value => 0}
      page.replace_html "kurs-text", search.name.downcase == "rupiah" ? "&nbsp;" : "Kurs"
    end
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
        page.replace_html "payment-record-#{params[:id]}", :partial => "payment_record", :locals => {:purchase => AccountingPurchaseBalance.find(params[:id]) }
      else
        page.replace_html "payment-record-#{params[:id]}", ""
      end
      page.replace_html "show-hide-payment-record-#{params[:id]}", :partial => "payment_record_trigger", :locals => {:purchase => AccountingPurchaseBalance.find(params[:id]), :show => !params[:show] }
    end
  end

  def do_payment
    @liability = Liability.new
    @purchase = AccountingPurchaseBalance.find(params[:id])
    render :layout => false
  end

  def create_payment
    purchase = AccountingPurchaseBalance.find(params[:purchase_balance_id])

    @liability = Liability.new(params[:liability])
    @liability.created_at = params[:liability_updated_at]
    @liability.last_value = purchase.amount_account_receivable - params[:liability][:payed_value].to_f
    @liability.purchase = purchase

    $selected_month, $selected_year = purchase.created_at.strftime("%m"), purchase.created_at.strftime("%Y")

    purchase_attributes = {}
    purchase_attributes[:amount_account_receivable] = purchase.amount_account_receivable - params[:liability][:payed_value].to_i
    purchase_attributes[:paid] = purchase.paid + params[:liability][:payed_value].to_i

    manual_journal = AccountingManualJournal.new
    manual_journal.created_at = params[:liability_updated_at]
    manual_journal.evidence = params[:liability][:evidence]
    manual_journal.editable = false

    journal_value = purchase.currency.name.downcase == "rupiah" ? params[:liability][:payed_value] : params[:liability][:payed_value].to_i * purchase.kurs.to_i
    debit_journal = AccountingJournalValue.new(
      :account_id => AccountingPurchaseDebitCredit.find_by_account_type('payable').account_id,
      :value => journal_value,
      :is_debit => true
    )
    manual_journal.values << debit_journal

    credit_journal = AccountingJournalValue.new(
      :account_id => AccountingPurchaseDebitCredit.find_by_account_type('cash').account_id,
      :value => journal_value,
      :is_debit => false
    )
    manual_journal.values << credit_journal

    @liability.manual_journal = manual_journal

    respond_to do |format|
      if purchase.update_attributes(purchase_attributes) && @liability.save
        flash[:notice] = 'Pembayaran utang berhasil disimpan'
        format.xml  { head :ok }
      else
        flash[:error] = 'Pembayaran utang disimpan'
        format.xml  { render :xml => purchase.errors, :status => :unprocessable_entity }
      end
      case params[:from]
      when 'm'
        format.html { redirect_to(accounting_liability_maturities_path) }
      when 'p'
        format.html { redirect_to(accounting_purchase_balances_path) }
      end
    end
  end

  private
  
  def initial_method
    @title = "DAFTAR TRANSAKSI PEMBELIAN"
    @periode = true
  end
end
