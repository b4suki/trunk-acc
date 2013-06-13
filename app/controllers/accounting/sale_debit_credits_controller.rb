class Accounting::SaleDebitCreditsController < ApplicationController
 skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_account_code]
 before_filter :initiate_method
  def index
    @pos = 'sale_debit_credits/edit'
    @sale_debit_credits = AccountingSaleDebitCredit.find(:all)

   @sale_debit_credit_accounts = {
      :cash => ["Penerimaan Penjualan Tunai", AccountingSaleDebitCredit.find_by_account_type('cash')],
      :receivable => ["Piutang Penjualan", AccountingSaleDebitCredit.find_by_account_type('receivable')],
      :sale => ["Penjualan",AccountingSaleDebitCredit.find_by_account_type('sale')],
      :shipping => ["Pengiriman", AccountingSaleDebitCredit.find_by_account_type('shipping')],
      :shipping_contra => ["Contra Pengiriman", AccountingSaleDebitCredit.find_by_account_type('shipping_contra')],
      :discount => ["Potongan", AccountingSaleDebitCredit.find_by_account_type('discount')],
      :Bank => ["Bank", AccountingSaleDebitCredit.find_all_by_account_type('Bank')],
      :shipping_bank => ["Shipping Bank", AccountingSaleDebitCredit.find_all_by_account_type('shipping_bank')]
    }

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounting_sale_debit_credits }
    end
  end

  # GET /accounting_sale_debit_credits/1
  # GET /accounting_sale_debit_credits/1.xml
  def show
    @sale_debit_credit = AccountingSaleDebitCredit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sale_debit_credit }
    end
  end

  # GET /accounting_sale_debit_credits/new
  # GET /accounting_sale_debit_credits/new.xml
  def new
    @sale_debit_credit = AccountingSaleDebitCredit.new
    render :layout => false
  end

  # GET /accounting_sale_debit_credits/1/edit
  def edit
    @sale_debit_credit = AccountingSaleDebitCredit.find(params[:id])
    render :layout => false
  end

  # POST /accounting_sale_debit_credits
  # POST /accounting_sale_debit_credits.xml
  def create
    
    if params[:sale_debit_credit][:credit] == "1"
       params[:sale_debit_credit][:credit] = 1
       params[:sale_debit_credit][:debit] = 0
    elsif params[:sale_debit_credit][:debit] == "1"
       params[:sale_debit_credit][:credit] = 0
       params[:sale_debit_credit][:debit] = 1
    end
    @sale_debit_credit = AccountingSaleDebitCredit.new(params[:sale_debit_credit])
    @sale_debit_credit.account_type = params[:account_type]
    
    respond_to do |format|
      if @sale_debit_credit.save
        flash[:notice] = 'Tipe debit credit penjualan berhasil disimpan.'
        format.html { redirect_to(accounting_sale_debit_credits_path) }
        format.xml  { render :xml => @sale_debit_credit, :status => :created, :location => @sale_debit_credit }
      else
        flash[:notice] = 'Tipe debit credit penjualan gagal disimpan.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @sale_debit_credit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accounting_sale_debit_credits/1
  # PUT /accounting_sale_debit_credits/1.xml
  def update
       
    @sale_debit_credit = AccountingSaleDebitCredit.find(params[:id])    
    if params[:sale_debit_credit][:credit] == "1"
       params[:sale_debit_credit][:credit] = 1
       params[:sale_debit_credit][:debit] = 0
    elsif params[:sale_debit_credit][:debit] == "1"
       params[:sale_debit_credit][:credit] = 0
       params[:sale_debit_credit][:debit] = 1
    end
      
    respond_to do |format|
      if @sale_debit_credit.update_attributes(params[:sale_debit_credit])
      flash[:notice] = 'Tipe debit credit penjualan berhasil diupdate.'
        format.html { redirect_to(accounting_sale_debit_credits_path) }
        format.xml  { head :ok }
      else
      flash[:notice] = 'Tipe debit credit penjualan gagal diupdate.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sale_debit_credit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /accounting_sale_debit_credits/1
  # DELETE /accounting_sale_debit_credits/1.xml
  def destroy
    @sale_debit_credit = AccountingSaleDebitCredit.find(params[:id])
    
    if @sale_debit_credit.destroy 
      flash[:notice] = 'Tipe debit credit penjualan berhasil dihapus.'
    else
      flash[:notice] = 'Tipe debit credit penjualan gagal dihapus.'
    end

    respond_to do |format|
      format.html { redirect_to(accounting_sale_debit_credits_url) }
      format.xml  { head :ok }
    end
  end
  
  def auto_complete_for_account_code    
    search = params[:account][:code]
    @accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "autocomplete"
  end
  
  def initiate_method
    @title = "TIPE DEBIT KREDIT PENJUALAN"
  end
  
end
