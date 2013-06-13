class Accounting::BankBalancesController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_account_code, :auto_complete_for_contra_account_code, :auto_complete_sale_invoice, :auto_complete_purchase_invoice]
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
    @bank_balances ,@first_saldo ,@saldo_bank= [], 0, {}
    conditions = []
    conditions << "MONTH(created_at) = #{$month}"
    conditions << "YEAR(created_at) = #{$year}"
    conditions = conditions.join(" AND ")
    accounts_bank =  AccountingSaleDebitCredit.find(:all, :conditions => ["account_type = 'Bank' OR account_type = 'cash' OR account_type = 'shipping'  AND debit  = '1'"])
    date = params[:date] ? Time.mktime($year, $month, 1, 0, 0, 0, 0) : Time.now
    previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}
    accounts_bank.each  { |account|
      @saldo_bank.update(account.accounting_account.description => 0)
      account.values.each { |value|
        
        sale = AccountingSaleBalance.find(:first,:conditions => ["MONTH(created_at) = #{$month} AND YEAR(created_at) = #{$year} AND id = '#{value.sale_balance_id}'"] )
        (@saldo_bank[account.accounting_account.description] += value.total_value
          @bank_balances <<  {:calss => sale.class.to_s,:id =>nil,:created_at => !value.transfer_date.nil? ? Time.mktime(value.transfer_date.strftime("%y"), value.transfer_date.strftime("%m"),  value.transfer_date.strftime("%d"), 0, 0, 0, 0) : sale.created_at ,:cg_gb_no => '',:description => account.account_type == 'shipping' ? "Biaya Kirim #{sale.customer.name}" : "Sale Order #{sale.customer.name}",:bkk => 0 ,:bkm => 0, :transaction_value => value.total_value, :debit => true }) if sale != nil
      }
      manual_value = AccountingJournalValue.find(:all,:conditions => ["account_id = #{account.account_id}"])
      manual_value.each { |value|
        
        manual_jurnal =AccountingManualJournal.find(:first,:conditions => ["MONTH(created_at) = #{$month} AND YEAR(created_at) = #{$year} AND id = '#{value.journal_id}'"])
        (value.is_debit  ? @saldo_bank[value.account.description] += value.value : @saldo_bank[value.account.description] -= value.value
          @bank_balances <<  {:calss => manual_jurnal.class.to_s,:id =>nil,:created_at =>  manual_jurnal.created_at ,:cg_gb_no => '',
            :description => [manual_jurnal.editable == true ? "Pembayaran #{manual_jurnal.description}" : "Pembayaran Sales Order No Bukti #{manual_jurnal.evidence}"],:bkk => 0 ,:bkm => 0, :transaction_value => value.value, :debit => value.is_debit == true ? true : false }) if manual_jurnal != nil
      }if !manual_value.nil?

      first_saldo = TrialBalance.find(
        :first,
        :conditions => ["MONTH(transaction_date) = #{previous_date[:month]} AND YEAR(transaction_date) = #{previous_date[:year]} AND account_id = '#{account.account_id}'"]
      )
      @first_saldo += first_saldo.nil? ? 0 : first_saldo.last_saldo
    }
    bank_balances = AccountingBankBalance.find(:all, :conditions => conditions, :order => 'created_at')
    bank_balances.each { |data|
    data.debit  ? @saldo_bank[data.accounting_account.description] += data.transaction_value : @saldo_bank[data.accounting_account.description] -= data.transaction_value if bank_balances.nil?
     @bank_balances <<  {:calss => data.class.to_s,:id =>data.id,:created_at => data.created_at,:cg_gb_no =>data.job_id,:description => data.description,:bkk => data.bkk,:bkm => data.bkm ,:transaction_value => data.transaction_value, :debit => data.debit == true ? true : false}}
    @bank_balances.sort! { |x, y| x[:created_at] <=> y[:created_at] }
    @bank_balances = @bank_balances.paginate :page => params[:page]
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bank_balances }
      format.pdf  { 
        send_data render_to_pdf({
            :action => 'index.rpdf',
            :page => 'landscape',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename => "transaksi_bank_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "transaksi_bank_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end
  end
  
  def filter
    conditions = []
    conditions << "MONTH(created_at) = #{params[:date][:month]}"
    conditions << "YEAR(created_at) = #{params[:date][:year]}"
    conditions = conditions.join(" AND ")
    
    @bank_balances = AccountingBankBalance.find(:all, :conditions => conditions)
    @cost = AccountingBankBalance.find(:all, :conditions => conditions).size
    @pos = 'edit'
    render :action => :index  
  end

  # GET /accounting_bank_balances/1
  # GET /accounting_bank_balances/1.xml
  def show
    @bank_balance = AccountingBankBalance.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bank_balance }
    end
  end

  # GET /accounting_bank_balances/new
  # GET /accounting_bank_balances/new.xml
  def new
    @bank_balance = AccountingBankBalance.new
    render :layout => false
  end

  # GET /accounting_bank_balances/1/edit
  def edit
    @bank_balance = AccountingBankBalance.find(params[:id])
    render :layout => false
  end

  # POST /accounting_bank_balances
  # POST /accounting_bank_balances.xml
  def create
    @bank_balance = AccountingBankBalance.new(params[:bank_balance])
    @bank_balance.maturity_date = nil if params["maturity_date_checkbox"].nil?
    if "#{params[:bank_balance][:cash_book]}" == "bkm"
      @bank_balance.debit = "true"
      @bank_balance.credit = "false"
      @bank_balance.account_id = params[:bank_cash_type]
      @bank_balance.contra_account_id =  params[:bank_balance][:account_id]
      if @bank_balance.nil?
        @bank_balance.total_debit = @bank_balance.transaction_value
        @bank_balance.total_credit = "0"
        @bank_balance.cash_balance = "0"
      end
    elsif "#{params[:bank_balance][:cash_book]}" == "bkk"
      @bank_balance.debit = "false"
      @bank_balance.credit = "true"
      @bank_balance.account_id = params[:bank_balance][:account_id]
      @bank_balance.contra_account_id = params[:bank_cash_type]
      if @bank_balance.nil?
        @bank_balance.total_credit = @bank_balance.transaction_value
        @bank_balance.total_debit = "0"
        @bank_balance.cash_balance = "0"
      end
    end

    if params[:transaction_link]=="1"
      if params[:transaction_link_type]=="sale"
        @bank_balance.debit = true
        @bank_balance.credit = false
        @bank_balance.account_id = params[:bank_cash_type]
        @bank_balance.total_debit = @bank_balance.transaction_value
        @bank_balance.total_credit = 0
        sale_balance = AccountingSaleBalance.find(params[:sale_id])
        sale_balance.update_attribute("amount_account_payable", sale_balance.amount_account_payable + @bank_balance.transaction_value)
        sale_receivable_account_id = AccountingSaleDebitCredit.find_by_account_type("receivable").account_id
        @bank_balance.contra_account_id = sale_receivable_account_id
      elsif params[:transaction_link_type]=="purchase"
        @bank_balance.debit = false
        @bank_balance.credit = true
        @bank_balance.contra_account_id = params[:bank_cash_type]
        @bank_balance.total_debit = 0
        @bank_balance.total_credit = @bank_balance.transaction_value
        purchase_balance = AccountingPurchaseBalance.find(params[:purchase_id])
        purchase_balance.update_attribute("amount_account_receivable", purchase_balance.amount_account_receivable + @bank_balance.transaction_value)
        purchase_payable_account_id = AccountingPurchaseDebitCredit.find_by_account_type("payable").account_id
        @bank_balance.accounting_account = purchase_payable_account_id
      end
    end

    $selected_month, $selected_year = @bank_balance.created_at.strftime("%m"), @bank_balance.created_at.strftime("%Y")
    
    respond_to do |format|
      if @bank_balance.save
        flash[:notice] = 'Transaksi Bank berhasil dibuat.'
        format.xml  { render :xml => @bank_balance, :status => :created, :location => @bank_balance }
      else
        flash[:notice] = 'Transaksi Bank gagal dibuat.'
        format.xml  { render :xml => @bank_balance.errors, :status => :unprocessable_entity }
      end
      format.html { redirect_to(accounting_bank_balances_path) }
    end
  end

  # PUT /accounting_bank_balances/1
  # PUT /accounting_bank_balances/1.xml
  def update
    @bank_balance = AccountingBankBalance.find(params[:id])
    $selected_month, $selected_year = @bank_balance.created_at.strftime("%m"), @bank_balance.created_at.strftime("%Y")
    
    if "#{params[:bank_balance][:cash_book]}" == "bkm"
      @bank_balance.debit = "true"
      @bank_balance.credit = "false"
      params[:bank_balance][:contra_account_id] = params[:bank_balance][:account_id]
      params[:bank_balance][:account_id] = params[:bank_cash_type]
    elsif "#{params[:bank_balance][:cash_book]}" == "bkk"
      @bank_balance.debit = "false"
      @bank_balance.credit = "true"
      @bank_balance.account_id = params[:bank_balance][:account_id]
      params[:bank_balance][:contra_account_id] = params[:bank_cash_type]
    end

    if params["maturity_date_checkbox"].nil?
      params[:bank_balance].delete("maturity_date(1i)")
      params[:bank_balance].delete("maturity_date(2i)")
      params[:bank_balance].delete("maturity_date(3i)")
      params[:bank_balance]["maturity_date"] = nil
    end

    if params[:transaction_link]=="1"
      if params[:transaction_link_type]=="sale"
        @bank_balance.debit = true
        @bank_balance.credit = false
        @bank_balance.account_id = params[:bank_cash_type]
        @bank_balance.total_debit = params[:bank_balance][:transaction_value].to_i
        @bank_balance.total_credit = 0
        sale_balance = AccountingSaleBalance.find(params[:sale_id])
        sale_balance.update_attribute("amount_account_payable", sale_balance.amount_account_payable - @bank_balance.transaction_value + params[:bank_balance][:transaction_value].to_i)
        sale_receivable_account_id = AccountingSaleDebitCredit.find_by_account_type("receivable").account_id
        @bank_balance.contra_account_id = sale_receivable_account_id
      elsif params[:transaction_link_type]=="purchase"
        @bank_balance.debit = false
        @bank_balance.credit = true
        @bank_balance.contra_account_id = params[:bank_cash_type]
        @bank_balance.total_debit = 0
        @bank_balance.total_credit = params[:bank_balance][:transaction_value].to_i
        purchase_balance = AccountingPurchaseBalance.find(params[:purchase_id])
        purchase_balance.update_attribute("amount_account_receivable", purchase_balance.amount_account_receivable - @bank_balance.transaction_value + params[:bank_balance][:transaction_value].to_i)
        purchase_payable_account_id = AccountingPurchaseDebitCredit.find_by_account_type("payable").account_id
        @bank_balance.accounting_account = purchase_payable_account_id
      end
    end
    
    respond_to do |format|
      if @bank_balance.update_attributes(params[:bank_balance])
        flash[:notice] = 'Transaksi Bank berhasil diupdate.'
        format.xml  { head :ok }
      else
        flash[:notice] = 'Transaksi Bank gagal diupdate.'
        format.xml  { render :xml => @bank_balance.errors, :status => :unprocessable_entity }
      end
      format.html { redirect_to(accounting_bank_balances_path) }
    end
  end

  # DELETE /accounting_bank_balances/1
  # DELETE /accounting_bank_balances/1.xml
  def destroy
    @bank_balance = AccountingBankBalance.find(params[:id])
    $selected_month, $selected_year = @bank_balance.created_at.strftime("%m"), @bank_balance.created_at.strftime("%Y")
    
    if @bank_balance.destroy
      flash[:notice] = 'Transaksi Bank berhasil dihapus.'
    else
      flash[:notice] = 'Transaksi Bank gagal dihapus.'      
    end

    respond_to do |format|
      format.html { redirect_to(accounting_bank_balances_url) }
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

  def bank_help            
    render :layout => false
  end

  def saldo_new
    @cash_balance = AccountingCashBalance.new

    render :layout => false
  end

  def create_new_saldo
    created_time = Time.mktime( params[:date][:year].to_i, params[:date][:month].to_i, 1, 0, 0, 0, 0 )
    AccountingBankBalance.create(
      :description => "data saldo awal",
      :created_at => created_time.strftime("%Y-%m-%d 00:00:00"),
      :cash_balance => params[:saldo],
      :without_calculation => true
    )

    respond_to do |format|
      format.html { redirect_to(accounting_bank_balances_url) }
      format.xml  { head :ok }
    end
  end

  def prepare_show_transaction_type
    render :update do |page|
      page.replace_html "invoice-input", :partial => "invoice_input_#{params[:type]}"
    end
  end

  def remove_unnecessary_field
    render :update do |page|
      if params[:stat]=="true"
        page.replace_html "account-validation-script", ""
        page << "$('transaction-link-type').setStyle({
            display: 'block'
        });
        jQuery('.to_remove').css({
            display: 'none'
        });"
      elsif params[:stat]=="false"
        page.replace_html "account-validation-script", :partial => "account_validation_script"
        page << "$('transaction-link-type').setStyle({
            display: 'none'
        });
        jQuery('.to_remove').css({
            display: 'block'
        });"
      end
    end
  end

  private
  
  def initial_method
    @title = "DAFTAR TRANSAKSI BANK"
    @periode = true
  end
end
