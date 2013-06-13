class Accounting::BankReconciliationsController < ApplicationController
  def index
    @bank_reconciliations = AccountingBankReconciliations.find(:all)
    @bank_reconciliations = AccountingBankReconciliations.new
    @detail_value = AccountingReconciliationDetailValues.new
    @reconciliation_company_debits = AccountingReconciliationDetail.find(:all, :conditions => ["company IS true AND debit IS true"])
    @reconciliation_company_credits = AccountingReconciliationDetail.find(:all, :conditions => ["company IS true AND credit IS true"])
    @reconciliation_bank_debits = AccountingReconciliationDetail.find(:all, :conditions => ["bank IS true AND debit IS true"])
    @reconciliation_bank_credits = AccountingReconciliationDetail.find(:all, :conditions => ["bank IS true AND credit IS true"])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounting_bank_reconciliations }
    end
  end

  # GET /accounting_bank_reconciliations/1
  # GET /accounting_bank_reconciliations/1.xml
  def show
    @bank_reconciliations = AccountingBankReconciliations.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bank_reconciliations }
    end
  end

  # GET /accounting_bank_reconciliations/new
  # GET /accounting_bank_reconciliations/new.xml
  def new
    @bank_reconciliations = AccountingBankReconciliations.new
    @detail_value = AccountingReconciliationDetailValues.new
    @reconciliation_company_debits = AccountingReconciliationDetail.find(:all, :conditions => ["company IS true AND debit IS true"])
    @reconciliation_company_credits = AccountingReconciliationDetail.find(:all, :conditions => ["company IS true AND credit IS true"])
    @reconciliation_bank_debits = AccountingReconciliationDetail.find(:all, :conditions => ["bank IS true AND debit IS true"])
    @reconciliation_bank_credits = AccountingReconciliationDetail.find(:all, :conditions => ["bank IS true AND credit IS true"])


    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bank_reconciliations }
    end
  end

  # GET /accounting_bank_reconciliations/1/edit
  def edit
    @bank_reconciliations = AccountingBankReconciliations.find(params[:id])
  end

  # POST /accounting_bank_reconciliations
  # POST /accounting_bank_reconciliations.xml
  def create
    @bank_reconciliations = AccountingBankReconciliations.new(params[:bank_reconciliations])
    @detail_value = AccountingReconciliationDetailValues.new(params[:detail_value])
    #@bank_reconciliations.bank_balance = format_currency(accumulate_cash_balance)
    respond_to do |format|
      if @bank_reconciliations.save    
        @detail_value.value = params[:vallue]
        @detail_value.save
        flash[:notice] = 'BankReconciliations was successfully created.'
        format.html { redirect_to(accounting_bank_reconciliation_path(@bank_reconciliations)) }
        format.xml  { render :xml => @bank_reconciliations, :status => :created, :location => @bank_reconciliations }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bank_reconciliations.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accounting_bank_reconciliations/1
  # PUT /accounting_bank_reconciliations/1.xml
  def update
    @bank_reconciliations = AccountingBankReconciliations.find(params[:id])

    respond_to do |format|
      if @bank_reconciliations.update_attributes(params[:bank_reconciliations])
        flash[:notice] = 'BankReconciliations was successfully updated.'
        format.html { redirect_to(accounting_bank_reconciliation_path(@bank_reconciliations)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bank_reconciliations.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /accounting_bank_reconciliations/1
  # DELETE /accounting_bank_reconciliations/1.xml
  def destroy
    @bank_reconciliations = AccountingBankReconciliations.find(params[:id])
    @bank_reconciliations.destroy

    respond_to do |format|
      format.html { redirect_to(accounting_bank_reconciliations_url) }
      format.xml  { head :ok }
    end
  end
end
