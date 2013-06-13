class Accounting::TaxesController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_account_code]
  before_filter :initiate_method
 
  def index
    @other_taxes = AccountingTax.find(:all, :conditions => "account_type IS NULL OR account_type=''")
    @taxes = {
      :ppn_masukan => ["Pajak Masukan", AccountingTax.find_by_account_type('ppn_masukan')],
      :ppn_keluaran => ["Pajak Keluaran", AccountingTax.find_by_account_type('ppn_keluaran')]
    }
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @taxes }
    end
  end

  def new
    @tax = AccountingTax.new
    render :layout => false
  end

  def create
    @tax = AccountingTax.new(params[:tax])
    if @tax.save
      redirect_to accounting_taxes_path
    end
  end

  def edit
    @tax = AccountingTax.find(params[:id])
    render :layout => false
  end

  def update
    @tax = AccountingTax.find(params[:id])
    if @tax.update_attributes(params[:tax])
      redirect_to accounting_taxes_path
    end
  end

  def destroy
    @tax = AccountingTax.find(params[:id])
    @tax.destroy
    redirect_to accounting_taxes_path
  end

  def auto_complete_for_account_code
    search = params[:account][:code]
    accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "shared/autocomplete", :locals => {:accounts => accounts}
  end

  private

  def initiate_method
    @title = "Daftar Pajak"
    @periode = false
  end
end
