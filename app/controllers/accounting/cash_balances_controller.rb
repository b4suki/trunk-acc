class Accounting::CashBalancesController < ApplicationController
  before_filter :login_required, :initial_method
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_account_code, :auto_complete_for_contra_account_code, :auto_complete_sale_invoice, :auto_complete_purchase_invoice]

  def index
    @cash_balances =[]
    if request.post? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]
    elsif request.get? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year
      $selected_month, $selected_year = nil, nil
    elsif request.get? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $month, $year = current_month, current_year
    end

    @date = {:month => $month, :year => $year}
    conditions = []
    conditions << "MONTH(created_at) = #{$month}"
    conditions << "YEAR(created_at) = #{$year}"
    conditions = conditions.join(" AND ")

    cash_balances = AccountingCashBalance.find(:all, :conditions => conditions, :order => 'created_at')
    cash_balances.each { |data| @cash_balances <<  {:calss => data.class.to_s,:id =>data.id,:created_at => data.created_at,:job_id =>data.job_id,:description => data.description,:bkk => data.bkk.nil? ? data.transaction_value : 0,:bkm => data.bkm.nil? ? data.transaction_value : 0}}
    purchase = AccountingPurchaseBalance.find(:all,:conditions => conditions )
    purchase.each { |data|
      data.values.each { |value|
        (@cash_balances <<  {:calss => data.class.to_s,:id =>nil,:created_at => data.created_at,:job_id =>data.job_id,:description => "Purchase Order #{data.vendor.name}",:bkk => 0,:bkm => value.total_value} ) if value.accounting_purchase_debit_credit.account_id == 2  }
    }
    sale = AccountingSaleBalance.find(:all,:conditions => conditions )
    sale.each { |data|
      data.values.each { |value|
        (@cash_balances <<  {:calss => data.class.to_s,:id =>nil,:created_at => data.created_at,:job_id =>data.job_id,:description => "Sale Order #{data.customer.name}",:bkk => value.accounting_sale_debit_credit.debit == true ? value.total_value : 0 ,:bkm => value.accounting_sale_debit_credit.debit == false ? value.total_value : 0} ) if value.accounting_sale_debit_credit.account_id == 2  }
    }
    manual = AccountingManualJournal.find(:all,:conditions => conditions )
    manual.each { |data|
      data.values.each { |value|
        (@cash_balances <<  {:calss => data.class.to_s,:id =>nil,:created_at => data.created_at,:job_id =>data.job_id,:description => [data.editable == true ? "Pembayaran #{data.description}"  : "Pembayaran Purchase Order No Bukti #{data.evidence}"],:bkk => value.is_debit == true ? value.value : 0 ,:bkm => value.is_debit == false ? value.value : 0} ) if value.account_id == 2  }
    }
    @cash_balances.sort! { |x, y| x[:created_at] <=> y[:created_at] }
    @cash_balances = @cash_balances.paginate :page => params[:page]
    @current_cash_account = AccountingCash.first
    @trial_balance = TrialBalance.first
    accounts = AccountingAccount.find(:first, :conditions => ["id=2"])
    date = params[:date] ? Time.mktime($year, $month, 1, 0, 0, 0, 0) : Time.now
    previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}
    @first_saldo = accounts.trial_balances.find(
      :first,
      :conditions => ["MONTH(transaction_date) = #{previous_date[:month]} AND YEAR(transaction_date) = #{previous_date[:year]}"]
    )
    @first_saldo = @first_saldo.nil? ? 0 : @first_saldo.last_saldo

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cash_balances }
      format.pdf  {
        send_data render_to_pdf({
            :action => 'index.rpdf',
            :page => 'landscape',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename => "transaksi_kas_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "transaksi_kas_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end
  end

  def show
    @cash_balance = AccountingCashBalance.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cash_balance }
    end
  end

  def new
    @cash_balance = AccountingCashBalance.new
    render :layout => false
  end

  def edit
    @cash_balance = AccountingCashBalance.find(params[:id])
    render :layout => false
  end

  def create
    @cash_balance = AccountingCashBalance.new(params[:cash_balance])
    $selected_month, $selected_year = @cash_balance.created_at.strftime("%m"), @cash_balance.created_at.strftime("%Y")
    cash_account_id = AccountingCash.first.account_id
    if params[:cash_balance][:cash_book]=="bkk"
      @cash_balance.account_id = params[:cash_balance][:account_id]
      @cash_balance.contra_account_id = cash_account_id
    elsif params[:cash_balance][:cash_book]=="bkm"
      @cash_balance.account_id = cash_account_id
      @cash_balance.contra_account_id = params[:cash_balance][:account_id]
    end

    if params[:transaction_link]=="1"
      if params[:transaction_link_type]=="sale"
        @cash_balance.account_id = cash_account_id
        sale_balance = AccountingSaleBalance.find(params[:sale_id])
        sale_balance.update_attribute("amount_account_payable", sale_balance.amount_account_payable + @cash_balance.transaction_value)
        sale_receivable_account_id = AccountingSaleDebitCredit.find_by_account_type("receivable").account_id
        @cash_balance.contra_account_id = sale_receivable_account_id
      elsif params[:transaction_link_type]=="purchase"
        @cash_balance.contra_account_id = cash_account_id
        purchase_balance = AccountingPurchaseBalance.find(params[:purchase_id])
        purchase_balance.update_attribute("amount_account_receivable", purchase_balance.amount_account_receivable + @cash_balance.transaction_value)
        purchase_payable_account_id = AccountingPurchaseDebitCredit.find_by_account_type("payable").account_id
        @cash_balance.account_id = purchase_payable_account_id
      end
    end

    respond_to do |format|
      if @cash_balance.save
        flash[:notice] = 'Transaksi Kas berhasil dibuat.'
        format.html { redirect_to(accounting_cash_balances_path)}
        format.xml  { render :xml => @cash_balance, :status => :created, :location => @cash_balance }
      else
        flash[:error] = 'Transaksi Kas gagal dibuat.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @cash_balance.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @cash_balance = AccountingCashBalance.find(params[:id])
    $selected_month, $selected_year = @cash_balance.created_at.strftime("%m"), @cash_balance.created_at.strftime("%Y")
    cash_account_id = AccountingCash.first.account_id
    if params[:cash_balance][:cash_book]=="bkk"
      params[:cash_balance][:contra_account_id] = cash_account_id
    elsif params[:cash_balance][:cash_book]=="bkm"
      params[:cash_balance][:contra_account_id] = params[:cash_balance][:account_id]
      params[:cash_balance][:account_id] = cash_account_id
    end

    if params[:transaction_link]=="1"
      if params[:transaction_link_type]=="sale"
        @cash_balance.account_id = cash_account_id
        sale_balance = AccountingSaleBalance.find(params[:sale_id])
        sale_balance.update_attribute("amount_account_payable", sale_balance.amount_account_payable - @cash_balance.transaction_value + params[:cash_balance][:transaction_value].to_i)
        sale_receivable_account = AccountingSaleDebitCredit.find_by_account_type("receivable")
        @cash_balance.contra_account = sale_receivable_account
      elsif params[:transaction_link_type]=="purchase"
        @cash_balance.contra_account_id = cash_account_id
        purchase_balance = AccountingPurchaseBalance.find(params[:purchase_id])
        purchase_balance.update_attribute("amount_account_receivable", purchase_balance.amount_account_receivable - @cash_balance.transaction_value + params[:cash_balance][:transaction_value].to_i)
        purchase_payable_account = AccountingPurchaseDebitCredit.find_by_account_type("payable")
        @cash_balance.account = purchase_payable_account
      end
    end
    
    respond_to do |format|
      if @cash_balance.update_attributes(params[:cash_balance])
        flash[:notice] = 'Transaksi Kas berhasil diupdate.'
        format.html { redirect_to(accounting_cash_balances_path) }
        format.xml  { head :ok }
      else
        flash[:error] = 'Transaksi Kas gagal diupdate.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cash_balance.errors, :status => :unprocessable_entity }
      end
    end
  end

  def cash_help
    render :layout => false
  end

  def destroy
    @cash_balance = AccountingCashBalance.find(params[:id])
    $selected_month, $selected_year = @cash_balance.created_at.strftime("%m"), @cash_balance.created_at.strftime("%Y")

    if @cash_balance.destroy
      flash[:notice] = 'Transaksi Kas berhasil dihapus.'
    else
      flash[:error] = 'Transaksi Kas gagal dihapus.'
    end

    respond_to do |format|
      format.html { redirect_to(accounting_cash_balances_url) }
      format.xml  { head :ok }
    end
  end

  def auto_complete_for_account_code
    search = params[:account][:code]
    @accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "autocomplete"
  end

  def auto_complete_for_contra_account_code
    search = params[:contra_account][:code]
    @accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "contra_account_autocomplete"
  end

  def auto_complete_for_invoice_sale
    search = params[:invoice][:sale]
    @sale_balances = AccountingSaleBalance.find(:all, :conditions => ["invoice_number LIKE ? ", "%#{search}%"])
    render :partial => "autocomplete_sale_invoice"
  end

  def auto_complete_for_invoice_purchase
    search = params[:invoice][:purchase]
    @purchase_balances = AccountingPurchaseBalance.find(:all, :conditions => ["invoice_number LIKE ? ", "%#{search}%"])
    render :partial => "autocomplete_purchase_invoice"
  end
  
  def saldo_new
    @cash_balance = AccountingCashBalance.new
    render :layout => false
  end

  def create_new_saldo
    created_time = Time.mktime( params[:date][:year].to_i, params[:date][:month].to_i, 1, 0, 0, 0, 0 )
    AccountingCashBalance.create(
      :description => "Saldo awal",
      :created_at => created_time.strftime("%Y-%m-%d 00:00:00"),
      :cash_balance => params[:saldo],
      :transaction_value => params[:saldo],
      :bkm => " ",
      :without_calculation => true
    )

    respond_to do |format|
      format.html { redirect_to(accounting_cash_balances_url) }
      format.xml  { head :ok }
    end
  end

  def prepare_show_transaction_type
    render :update do |page|
      page.replace_html "invoice-input", :partial => "invoice_input_#{params[:type]}"
    end
  end
  
  private

  def initial_method
    @title = "DAFTAR TRANSAKSI KAS"
    @periode = true
  end
end
