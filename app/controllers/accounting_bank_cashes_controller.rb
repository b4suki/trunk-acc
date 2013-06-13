class AccountingBankCashesController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_account_code]
  before_filter :initial_method

  # GET /accounting_bank_cashes
  # GET /accounting_bank_cashes.xml
  def index
    @pos = 'accounting_bank_cashes/edit'
    @accounting_bank_cashes = AccountingBankCash.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounting_bank_cashes }
    end
  end

  # GET /accounting_bank_cashes/1
  # GET /accounting_bank_cashes/1.xml
  def show
    @accounting_bank_cash = AccountingBankCash.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @accounting_bank_cash }
    end
  end

  # GET /accounting_bank_cashes/new
  # GET /accounting_bank_cashes/new.xml
  def new
    @accounting_bank_cash = AccountingBankCash.new

    render :layout => false
  end

  # GET /accounting_bank_cashes/1/edit
  def edit
    @accounting_bank_cash = AccountingBankCash.find(params[:id])
    render :layout => false
  end

  # POST /accounting_bank_cashes
  # POST /accounting_bank_cashes.xml
  def create
    @accounting_bank_cash = AccountingBankCash.new(params[:accounting_bank_cash])

    respond_to do |format|
      if @accounting_bank_cash.save
        flash[:notice] = 'Tipe kas bank berhasil disimpan.'
        format.html { redirect_to(accounting_bank_cashes_path) }
        format.xml  { render :xml => @accounting_bank_cash, :status => :created, :location => @accounting_bank_cash }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @accounting_bank_cash.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accounting_bank_cashes/1
  # PUT /accounting_bank_cashes/1.xml
  def update
    @accounting_bank_cash = AccountingBankCash.find(params[:id])
    @accounting_bank_cash.update_account_bank_sale_dabit_credit(@accounting_bank_cash.account_id,params[:accounting_bank_cash][:account_id])
    respond_to do |format|
      if @accounting_bank_cash.update_attributes(params[:accounting_bank_cash])
        flash[:notice] = 'Tipe kas bank berhasil diupdate.'
        format.html { redirect_to(accounting_bank_cashes_path) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Tipe kas bank gagal diupdate.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @accounting_bank_cash.errors, :status => :unprocessable_entity }
      end
    end

  end

  # DELETE /accounting_bank_cashes/1
  # DELETE /accounting_bank_cashes/1.xml

  def destroy
    @accounting_bank_cash = AccountingBankCash.find(params[:id])

    if @accounting_bank_cash.destroy
      flash[:notice] = 'Tipe kas bank berhasil dihapus.'
    else
      flash[:notice] = 'Tipe kas bank gagal dihapus.'
    end

    respond_to do |format|
      format.html { redirect_to(accounting_bank_cashes_url) }
      format.xml  { head :ok }
    end
  end

  def auto_complete_for_account_code
    search = params[:account][:code]
    @accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "autocomplete"
  end

  def initial_method
    @title = "TIPE KAS BANK"
  end
end
