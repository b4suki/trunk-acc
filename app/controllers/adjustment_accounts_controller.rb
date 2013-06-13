class AdjustmentAccountsController < ApplicationController
  # GET /adjustment_accounts
  # GET /adjustment_accounts.xml
  layout "application"
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_account_code]
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

    respond_to do |format|
      if @adjustment_account.save
        flash[:notice] = 'AdjustmentAccount was successfully created.'
        format.html { redirect_to(adjustment_accounts_path) }
        format.xml  { render :xml => @adjustment_account, :status => :created, :location => @adjustment_account }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @adjustment_account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /adjustment_accounts/1
  # PUT /adjustment_accounts/1.xml
  def update
    @adjustment_account = AdjustmentAccount.find(params[:id])

    respond_to do |format|
      if @adjustment_account.update_attributes(params[:adjustment_account])
        flash[:notice] = 'AdjustmentAccount was successfully updated.'
        format.html { redirect_to(adjustment_accounts_path) }
        format.xml  { head :ok }
      else
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
    @adjustment_account.destroy

    respond_to do |format|
      format.html { redirect_to(adjustment_accounts_path) }
      format.xml  { head :ok }
    end
  end
end
