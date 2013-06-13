class Accounting::SaleSignaturesController < ApplicationController
  before_filter :login_required, :initial_method

  def index
    @sale_signatures = AccountingSaleSignature.find(:all)
  end

  def new
    @sale_signature = AccountingSaleSignature.new
    render :layout => false
  end

  def create
    @sale_signature = AccountingSaleSignature.new(params[:sale_signature])

    if @sale_signature.save
      flash[:notice] = "Penanda tangan berhasil dibuat"
    else
      flash[:notice] = "Penanda tangan gagal dibuat"
    end
    redirect_to accounting_sale_signatures_path
  end

  def edit
    @sale_signature = AccountingSaleSignature.find(params[:id])
    render :layout => false
  end

  def update
    @sale_signature = AccountingSaleSignature.find(params[:id])

    if @sale_signature.update_attributes(params[:sale_signature])
      flash[:notice] = "Penanda tangan berhasil diupdate"
    else
      flash[:notice] = "Penanda tangan gagal diupdate"
    end
    redirect_to accounting_sale_signatures_path
  end

  def destroy
    @sale_signature = AccountingSaleSignature.find(params[:id])

    if @sale_signature.destroy
      flash[:notice] = "Penanda tangan berhasil dihapus"
    else
      flash[:notice] = "Penanda tangan gagal dihapus"
    end
    redirect_to accounting_sale_signatures_path
  end

  private
  def initial_method
    @title = "Tanda Tangan Perusahaan pada Invoice"
    @periode = false
  end
end
