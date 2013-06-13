class AccountingCashesController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_account_code]
  before_filter :initiate_method

  def index
    @pos = 'accounting_cashes/edit'
    @accounting_cashes = AccountingCash.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounting_cashes }
    end
  end

  def show
    @accounting_cash = AccountingCash.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @accounting_cash }
    end
  end

  def new
    @accounting_cash = AccountingCash.new

    render :layout => false
  end

  def edit
    @accounting_cash = AccountingCash.find(params[:id])
    render :layout => false
  end

  def create
    @accounting_cash = AccountingCash.new(params[:accounting_cash])

    respond_to do |format|
      if @accounting_cash.save
        flash[:notice] = 'Tipe kas berhasil disimpan.'
        format.html { redirect_to(accounting_cashes_path) }
        format.xml  { render :xml => @accounting_cash, :status => :created, :location => @accounting_cash }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @accounting_cash.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @accounting_cash = AccountingCash.find(params[:id])

    respond_to do |format|
      if @accounting_cash.update_attributes(params[:accounting_cash])
        flash[:notice] = 'Tipe Kas berhasil diupdate.'
        format.html { redirect_to(accounting_cashes_path) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Tipe Kas gagal diupdate.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @accounting_cash.errors, :status => :unprocessable_entity }
      end
    end

  end

  def destroy
    @accounting_cash = AccountingCash.find(params[:id])

    if @accounting_cash.destroy
      flash[:notice] = 'Tipe Kas berhasil dihapus.'
    else
      flash[:notice] = 'Tipe Kas gagal dihapus.'
    end

    respond_to do |format|
      format.html { redirect_to(accounting_cashes_url) }
      format.xml  { head :ok }
    end
  end

  def auto_complete_for_account_code
    search = params[:account][:code]
    @accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "autocomplete"
  end

  def initiate_method
    @title = "KAS YANG SEDANG DIGUNAKAN"
  end
end
