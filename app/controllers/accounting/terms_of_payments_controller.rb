class Accounting::TermsOfPaymentsController < ApplicationController
# skip_before_filter :verify_authenticity_token
 before_filter :initiate_method
  def index
    @terms_of_payments = AccountingTermsOfPayment.find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounting_terms_of_payments }
    end
  end

  # GET /accounting_sale_debit_credits/1
  # GET /accounting_sale_debit_credits/1.xml
  def show
    @terms_of_payment = AccountingTermsOfPayment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @terms_of_payment }
    end
  end

  # GET /accounting_sale_debit_credits/new
  # GET /accounting_sale_debit_credits/new.xml
  def new
     @terms_of_payment = AccountingTermsOfPayment.new
    render :layout => false
  end

  # GET /accounting_sale_debit_credits/1/edit
  def edit
     @terms_of_payment = AccountingTermsOfPayment.find(params[:id])
  end

  # POST /accounting_sale_debit_credits
  # POST /accounting_sale_debit_credits.xml
  def create   
    @terms_of_payment = AccountingTermsOfPayment.new(params[:terms_of_payment])
    
    respond_to do |format|
      if @terms_of_payment.save
        flash[:notice] = 'Jenis Pembayaran berhasil disimpan.'
        format.html { redirect_to(accounting_terms_of_payments_path) }
        format.xml  { render :xml => @terms_of_payment, :status => :created, :location => @terms_of_payment }
      else
        flash[:notice] = 'Jenis Pembayaran gagal disimpan.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @terms_of_payment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accounting_sale_debit_credits/1
  # PUT /accounting_sale_debit_credits/1.xml
  def update
       
    @terms_of_payment = AccountingTermsOfPayment.find(params[:id])    
          
    respond_to do |format|
      if @terms_of_payment.update_attributes(params[:terms_of_payment])
      flash[:notice] = 'Jenis Pembayaran berhasil diupdate.'
        format.html { redirect_to(accounting_terms_of_payments_path) }
        format.xml  { head :ok }
      else
      flash[:notice] = 'Jenis Pembayaran gagal diupdate.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @terms_of_payment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /accounting_sale_debit_credits/1
  # DELETE /accounting_sale_debit_credits/1.xml
  def destroy
    @terms_of_payment = AccountingTermsOfPayment.find(params[:id])
    
    if @terms_of_payment.destroy 
      flash[:notice] = 'Tipe Pembayaran berhasil dihapus.'
    else
      flash[:notice] = 'Tipe Pembayaran gagal dihapus.'
    end

    respond_to do |format|
      format.html { redirect_to(accounting_terms_of_payments_url) }
      format.xml  { head :ok }
    end
  end
  
  def auto_complete_for_account_code    
    search = params[:account][:code]
    @accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "autocomplete"
  end
  
  def initiate_method
    @title = "Jenis Pembayaran"
  end
end
