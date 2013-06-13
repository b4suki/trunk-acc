class Accounting::TransactionTypesController < ApplicationController
  # GET /accounting_transaction_types
  # GET /accounting_transaction_types.xml
#  access_control [:new, :create, :update, :edit, :destroy ] => 'Inventory | Administrator'
  def index
    @transaction_types = AccountingTransactionType.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounting_transaction_types }
    end
  end

  # GET /accounting_transaction_types/1
  # GET /accounting_transaction_types/1.xml
  def show
    @transaction_type = AccountingTransactionType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @transaction_type }
    end
  end

  # GET /accounting_transaction_types/new
  # GET /accounting_transaction_types/new.xml
  def new
    @transaction_type = AccountingTransactionType.new
    render :layout => false
  end

  # GET /accounting_transaction_types/1/edit
  def edit
    @transaction_type = AccountingTransactionType.find(params[:id])
    render :layout => false
  end

  # POST /accounting_transaction_types
  # POST /accounting_transaction_types.xml
  def create
    @transaction_type = AccountingTransactionType.new(params[:transaction_type])

    respond_to do |format|
      if @transaction_type.save
        flash[:notice] = 'Transaction Type was successfully created.'
        format.html { redirect_to(accounting_transaction_types_path) }
        format.xml  { render :xml => @transaction_type, :status => :created, :location => @transaction_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @transaction_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accounting_transaction_types/1
  # PUT /accounting_transaction_types/1.xml
  def update
    @transaction_type = AccountingTransactionType.find(params[:id])

    respond_to do |format|
      if @transaction_type.update_attributes(params[:transaction_type])
        flash[:notice] = 'Transaction Type was successfully updated.'
        format.html { redirect_to(accounting_transaction_types_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @transaction_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /accounting_transaction_types/1
  # DELETE /accounting_transaction_types/1.xml
  def destroy
    @transaction_type = AccountingTransactionType.find(params[:id])
    @transaction_type.destroy

    respond_to do |format|
      format.html { redirect_to(accounting_transaction_types_url) }
      format.xml  { head :ok }
    end
  end
end
