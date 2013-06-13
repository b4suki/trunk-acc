class Accounting::AdjustmentAccountsController < ApplicationController  
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_account_code]
  before_filter :initiate_methode
  def index
    @adjustment_accounts = AdjustmentAccount.find(:all)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @adjustment_accounts }
    end
  end

  # GET /adjustment_accounts/1
  # GET /adjustment_accounts/1.xml
  def show
    @adjustment_account = AdjustmentAccount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @adjustment_account }
    end
  end

  # GET /adjustment_accounts/new
  # GET /adjustment_accounts/new.xml
  def new
    @adjustment_account = AdjustmentAccount.new
    render :layout => false
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @adjustment_account }
#    end
  end

  # GET /adjustment_accounts/1/edit
  def edit
    @adjustment_account = AdjustmentAccount.find(params[:id])
    render :layout => false 
  end

  # POST /adjustment_accounts
  # POST /adjustment_accounts.xml
  def create    
    @adjustment_account = AdjustmentAccount.new(params[:adjustment_account])
    
    if params[:combo][:value] == "Credit"
       params[:adjustment_account][:debit_credit] = 1       
    else
       params[:adjustment_account][:debit_credit] = 0              
    end

    respond_to do |format|
      if @adjustment_account.save
        flash[:notice] = 'Kode Rekening AJE berhasil disimpan.'
        format.html { redirect_to(accounting_adjustment_accounts_path) }
        format.xml  { render :xml => @adjustment_account, :status => :created, :location => @adjustment_account }
      else
        flash[:notice] = 'Kode Rekening AJE gagal disimpan.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @adjustment_account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /adjustment_accounts/1
  # PUT /adjustment_accounts/1.xml
  def update
    @adjustment_account = AdjustmentAccount.find(params[:id])
    if params[:combo][:value] == "Credit"
      params[:adjustment_account][:debit_credit] = 1       
    else
      params[:adjustment_account][:debit_credit] = 0              
    end

    respond_to do |format|
      if @adjustment_account.update_attributes(params[:adjustment_account])
        flash[:notice] = 'Kode Rekening AJE berhasil diupdate.'
        format.html { redirect_to(accounting_adjustment_accounts_path) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Kode Rekening AJE gagal diupdate.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @adjustment_account.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def auto_complete_for_account_code    
    search = params[:account][:code]
    @accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "autocomplete"
  end

  # DELETE /adjustment_accounts/1
  # DELETE /adjustment_accounts/1.xml
  def destroy
    @adjustment_account = AdjustmentAccount.find(params[:id])
    
    if @adjustment_account.destroy
      flash[:notice] = 'Kode Rekening AJE berhasil dihapus.'
    else
      flash[:notice] = 'Kode Rekening AJE gagal dihapus.'
    end

    respond_to do |format|
      format.html { redirect_to(accounting_adjustment_accounts_path) }
      format.xml  { head :ok }
    end
  end
  
  def initiate_methode
    @title = "Rekening Aktiva Tetap"
  end
end
