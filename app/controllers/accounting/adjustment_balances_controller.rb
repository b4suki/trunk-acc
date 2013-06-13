class Accounting::AdjustmentBalancesController < ApplicationController
  before_filter :initiate_method
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_account_code,:auto_complete_for_contra_account_code]

  def index

    if request.post? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]
    elsif request.get? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year
      $selected_month, $selected_year = nil, nil
    elsif request.get? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $month, $year = current_month, current_year      
    end
    conditions = []
    conditions << "MONTH(transaction_date) = #{$month}"
    conditions << "YEAR(transaction_date) = #{$year}"
    conditions = conditions.join(" AND ")    
    @results = AccountingFixedAssetDetail.find(:all, :conditions => conditions, :group => 'account_id')#, :conditions => conditions ) 

    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @results }
      format.pdf  { 
        send_data render_to_pdf({
            :action => 'index.rpdf', 
            :page => 'landscape',
            :size => '60x60cm',
            :layout => 'pdf_report'
          }), :filename =>  "adjustment_entry_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "adjustment_entry_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end
  end
  
  def edit
    @adjustment_balance = AccountingAdjustmentBalance.find(params[:id])
    render :layout => false
  end
  
  def initiate_method
    @title = 'Adjusment Entries'
    @periode = true
  end

  def create    
    @adjustment_balance = AccountingAdjustmentBalance.new(params[:adjustment_balance])
    respond_to do |format|
      if @adjustment_balance.save          
        flash[:notice] = 'Transaksi Adjustment berhasil dibuat.'
        format.html { redirect_to(accounting_adjustment_balances_path) }
        format.xml  { render :xml => @adjustment_balance, :status => :created, :location => @adjustment_balance }
      else        
        flash[:notice] = 'Transaksi Adjustment gagal dibuat.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @adjustment_balance.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @adjustment_balance = AccountingAdjustmentBalance.find(params[:id])
    
    respond_to do |format|
      if @adjustment_balance.update_attributes(params[:adjustment_balance])
        flash[:notice] = 'Transaksi Adjustment berhasil diupdate.'
        format.html { redirect_to(accounting_adjustment_balances_path) }
        format.xml  { render :xml => @adjustment_balance, :status => :created, :location => @adjustment_balance }
      else
        flash[:notice] = 'Transaksi Adjustment gagal diupdate.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @adjustment_balance.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def new
    @adjustment_balance = AccountingAdjustmentBalance.new
    render :layout => false
  end
  
  def destroy
    @adjustment_balance = AccountingAdjustmentBalance.find(params[:id])
    respond_to do |format|
      if @adjustment_balance.destroy
        flash[:notice] = 'Transaksi Adjustment berhasil dihapus.'
        format.html { redirect_to(accounting_adjustment_balances_path) }
        format.xml  { render :xml => @adjustment_balance, :status => :created, :location => @adjustment_balance }
      else
        flash[:notice] = 'Transaksi Adjustment gagal dihapus.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @adjustment_balance.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def auto_complete_for_account_code
    search = params[:account][:code]
    @accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "autocomplete"
  end
  
  def auto_complete_for_contra_account_code
    search = params[:contra_account][:code]
    @accounts = AccountingAccount.find(:all, :conditions => ["code LIKE ? OR description LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "contra_account_autocomplete"
  end
  
end
