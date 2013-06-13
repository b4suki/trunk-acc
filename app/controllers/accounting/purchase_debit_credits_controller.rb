class Accounting::PurchaseDebitCreditsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_account_code]
  before_filter :initiate_method

  def index
    @purchase_debit_credits = AccountingPurchaseDebitCredit.find(:all)
    @purchase_debit_credit_accounts = {
      :purchase => ["Pembelian", AccountingPurchaseDebitCredit.find_by_account_type('purchase')],
      :cash => ["Pembelian Tunai", AccountingPurchaseDebitCredit.find_by_account_type('cash')],
      :payable => ["Utang Pembelian", AccountingPurchaseDebitCredit.find_by_account_type('payable')],
      :discount => ["Potongan", AccountingPurchaseDebitCredit.find_by_account_type('discount')],
      :shipping_debit => ["Pengiriman", AccountingPurchaseDebitCredit.find_by_account_type('shipping_debit')],
      :shipping_credit => ["Contra Pengiriman", AccountingPurchaseDebitCredit.find_by_account_type('shipping_credit')]
    }

    respond_to do |format|
      format.html
      format.xml  { render :xml => @purchase_debit_credits }
    end
  end

  def show
    @purchase_debit_credit = AccountingPurchaseDebitCredit.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @purchase_debit_credit }
    end
  end

  def new
    @purchase_debit_credit = AccountingPurchaseDebitCredit.new
    render :layout => false
  end

  def edit
    @purchase_debit_credit = AccountingPurchaseDebitCredit.find(params[:id])
    render :layout => false
  end

  def create
    if params[:purchase_debit_credit][:credit] == "1"
      params[:purchase_debit_credit][:credit] = 1
      params[:purchase_debit_credit][:debit] = 0
    elsif params[:purchase_debit_credit][:debit] == "1"
      params[:purchase_debit_credit][:credit] = 0
      params[:purchase_debit_credit][:debit] = 1
    end
    
    @purchase_debit_credit = AccountingPurchaseDebitCredit.new(params[:purchase_debit_credit])
    @purchase_debit_credit.account_type = params[:account_type].nil? ? nil : params[:account_type]
    
    respond_to do |format|
      if @purchase_debit_credit.save
        flash[:notice] = 'Tipe debit credit pembelian berhasil disimpan.'
        format.html { redirect_to(accounting_purchase_debit_credits_path) }
        format.xml  { render :xml => @purchase_debit_credit, :status => :created, :location => @purchase_debit_credit }
      else
        flash[:notice] = 'Tipe debit credit pembelian gagal disimpan.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @purchase_debit_credit.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @purchase_debit_credit = AccountingPurchaseDebitCredit.find(params[:id])
#    if params[:combo][:value] == "Credit"
    if params[:purchase_debit_credit][:credit] == "1"
       params[:purchase_debit_credit][:credit] = 1
       params[:purchase_debit_credit][:debit] = 0
#    else
    elsif params[:sale_debit_credit][:debit] == "1"
       params[:purchase_debit_credit][:credit] = 0
       params[:purchase_debit_credit][:debit] = 1
    end
    
    respond_to do |format|
      if @purchase_debit_credit.update_attributes(params[:purchase_debit_credit])
        flash[:notice] = 'Tipe debit credit pembelian berhasil diupdate.'
        format.html { redirect_to(accounting_purchase_debit_credits_path) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Tipe debit credit pembelian gagal diupdate.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @purchase_debit_credit.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def auto_complete_for_account_code    
    search = params[:account][:code]
    @accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "autocomplete"
  end
  

  def destroy
    @purchase_debit_credit = AccountingPurchaseDebitCredit.find(params[:id])
    
    if @purchase_debit_credit.destroy
      flash[:notice] = 'Tipe debit credit pembelian berhasil dihapus.'
    else
      flash[:notice] = 'Tipe debit credit pembelian gagal dihapus.'
    end

    respond_to do |format|
      format.html { redirect_to(accounting_purchase_debit_credits_url) }
      format.xml  { head :ok }
    end
  end
  
  def initiate_method
    @title = "TIPE DEBIT KREDIT PEMBELIAN"
  end
end
