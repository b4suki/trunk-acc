class Accounting::CashFlowDebitCreditsController < ApplicationController
  before_filter :initial_method, :login_required
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_account_code]

  def index
    @operating_activity = AccountingCashFlowActivity.find_by_name("operasi")
    @investing_activity = AccountingCashFlowActivity.find_by_name("investasi")
    @financing_activity = AccountingCashFlowActivity.find_by_name("pendanaan")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @operating_activity + @investing_activity + @financing_activity }
    end
  end

  def new
    @accounting_cash_flow_debit_credit = AccountingCashFlowDebitCredit.new
    render :layout => false
  end

  def create
    @accounting_cash_flow_debit_credit = AccountingCashFlowDebitCredit.new(params[:accounting_cash_flow_debit_credit])
    if @accounting_cash_flow_debit_credit.save
      flash[:notice] = "Berhasil disimpan"
    else
      flash[:notice] = "Gagal disimpan"
    end
    redirect_to accounting_cash_flow_debit_credits_path
  end

  def edit
    @accounting_cash_flow_debit_credit = AccountingCashFlowDebitCredit.find(params[:id])
    render :layout => false
  end

  def update
    @accounting_cash_flow_debit_credit = AccountingCashFlowDebitCredit.find(params[:id])
    if @accounting_cash_flow_debit_credit.update_attributes(params[:accounting_cash_flow_debit_credit])
      flash[:notice] = "Berhasil diupdate"
    else
      flash[:notice] = "Gagal diupdate"
    end
    redirect_to accounting_cash_flow_debit_credits_path
  end

  def destroy
    @accounting_cash_flow_debit_credit = AccountingCashFlowDebitCredit.find(params[:id])
    if @accounting_cash_flow_debit_credit.destroy
      flash[:notice] = "Berhasil dihapus"
    else
      flash[:notice] = "Gagal dihapus"
    end
    redirect_to accounting_cash_flow_debit_credits_path
  end

  def auto_complete_for_account_code
    search = params[:account][:code]
    @accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    @accounts = @accounts
    render :partial => "autocomplete"
  end

  private
  def initial_method
    @title = "pengaturan account untuk laporan cash flow".upcase
  end
end
