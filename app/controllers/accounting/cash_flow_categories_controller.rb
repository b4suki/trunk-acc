class Accounting::CashFlowCategoriesController < ApplicationController
  def new
    @accounting_cash_flow_category = AccountingCashFlowCategory.new
    render :layout => false
  end

  def create
    @accounting_cash_flow_category = AccountingCashFlowCategory.new(params[:accounting_cash_flow_category])
    if @accounting_cash_flow_category.save
      flash[:notice] = "Berhasil disimpan"
    else
      flash[:notice] = "Gagal disimpan"
    end
    redirect_to accounting_cash_flow_debit_credits_path
  end

  def edit
    @accounting_cash_flow_category = AccountingCashFlowCategory.find(params[:id])
    render :layout => false
  end

  def update
    @accounting_cash_flow_category = AccountingCashFlowCategory.find(params[:id])
    if @accounting_cash_flow_category.update_attributes(params[:accounting_cash_flow_category])
      flash[:notice] = "Berhasil diupdate"
    else
      flash[:notice] = "Gagal diupdate"
    end
    redirect_to accounting_cash_flow_debit_credits_path
  end

  def destroy
    @accounting_cash_flow_category = AccountingCashFlowCategory.find(params[:id])
    if @accounting_cash_flow_category.destroy
      flash[:notice] = "Berhasil dihapus"
    else
      flash[:notice] = "Gagal dihapus"
    end
    redirect_to accounting_cash_flow_debit_credits_path
  end
end
