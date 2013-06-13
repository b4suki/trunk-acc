class Accounting::ReconciliationDetailsController < ApplicationController
  def index
    @reconciliation_company_debits = AccountingReconciliationDetail.find(:all, :conditions => ["company IS true AND debit IS true"])
    @reconciliation_company_credits = AccountingReconciliationDetail.find(:all, :conditions => ["company IS true AND credit IS true"])
    @reconciliation_bank_debits = AccountingReconciliationDetail.find(:all, :conditions => ["bank IS true AND debit IS true"])
    @reconciliation_bank_credits = AccountingReconciliationDetail.find(:all, :conditions => ["bank IS true AND credit IS true"])
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounting_reconciliation_details }
    end
  end

  # GET /accounting_reconciliation_details/1
  # GET /accounting_reconciliation_details/1.xml
  def show
    @reconciliation_detail = AccountingReconciliationDetail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @reconciliation_detail }
    end
  end

  # GET /accounting_reconciliation_details/new
  # GET /accounting_reconciliation_details/new.xml
  def new
    @reconciliation_detail = AccountingReconciliationDetail.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @reconciliation_detail }
    end
  end

  # GET /accounting_reconciliation_details/1/edit
  def edit
    @reconciliation_detail = AccountingReconciliationDetail.find(params[:id])
  end

  # POST /accounting_reconciliation_details
  # POST /accounting_reconciliation_details.xml
  def create
    @reconciliation_detail = AccountingReconciliationDetail.new(params[:reconciliation_detail])

    respond_to do |format|
      if @reconciliation_detail.save
        flash[:notice] = 'ReconciliationDetail was successfully created.'
        format.html { redirect_to(accounting_reconciliation_details_url) }
        format.xml  { render :xml => @reconciliation_detail, :status => :created, :location => @reconciliation_detail }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @reconciliation_detail.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accounting_reconciliation_details/1
  # PUT /accounting_reconciliation_details/1.xml
  def update
    @reconciliation_detail = AccountingReconciliationDetail.find(params[:id])

    respond_to do |format|
      if @reconciliation_detail.update_attributes(params[:reconciliation_detail])
        flash[:notice] = 'ReconciliationDetail was successfully updated.'
        format.html { redirect_to(accounting_reconciliation_details_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reconciliation_detail.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /accounting_reconciliation_details/1
  # DELETE /accounting_reconciliation_details/1.xml
  def destroy
    @reconciliation_detail = AccountingReconciliationDetail.find(params[:id])
    @reconciliation_detail.destroy

    respond_to do |format|
      format.html { redirect_to(accounting_reconciliation_details_url) }
      format.xml  { head :ok }
    end
  end
end
