class ExchangesController < ApplicationController
  before_filter :login_required
  def index
    @exchanges = ExchangeRate.get_all_list_exchange
  end
  
  def edit
    @exchange = ExchangeRate.get_by_id(params[:id])
  end
  
  def update
    @exchange = ExchangeRate.get_by_id(params[:id])

    respond_to do |format|
      if @exchange.update_attributes(params[:exchange])
        flash[:notice] = 'Nilai Tukar berhasil diupdate.'
        format.html { redirect_to(exchanges_path) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Nilai Tukar gagal diupdate.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @exchange.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def convert
    
  end
  
  def currency_exchange
    amount = params[:amount].to_f
    result = CurrencyExchange.currency_exchange(amount,params[:exchange][:from],params[:exchange][:to])
    render :update do |page|
      page.replace_html "result", "#{result}"
    end
  end
end
