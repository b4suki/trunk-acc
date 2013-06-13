class Accounting::LiabilityMutationsController < ApplicationController
  before_filter :login_required, :initial_method
  
  def index
    if request.post? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]      
     # $type = params[:filter][:type]
    elsif request.get? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year
      $selected_month, $selected_year = nil, nil
    elsif request.get? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $type = "maturity_date"
      $month, $year = current_month, current_year
    end
    conditions = []
    conditions << "MONTH(#{$type}) = #{$month}"
    conditions << "YEAR(#{$type}) = #{$year}"
    conditions << "status_id != '2'"
    conditions = conditions.join(" AND ")
    
    
    @mutations = AccountingPurchaseBalance.find(:all, 
                                                #:conditions => ["accounting_mutations.type='Liability' "], 
                                                #:joins => "left join accounting_mutations on accounting_mutations.transaction_id = accounting_purchase_balances.id",
                                                :include => :accounting_mutation,
                                                :group => 'vendor_id'
                                              )
                                          #    p @mutations
    #@mutations = AccountingMutation.find(:all, :conditions => ["month(updated_at) =  #{$month} and year(updated_at)=#{$year} and type='Liability' "], :group => 'vendor_customer_id')
    #@liability = AccountingPurchaseBalance.find(:all, :conditions => conditions, :joins => "ET")
    #apap @mutations + @liability
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @liabilities }
      format.pdf  {
        send_data render_to_pdf({
          :action => 'index.rpdf',
          :page => 'portrait',
          :size => '30x60cm',
          :layout => 'pdf_report'
        }), :filename => "mutasi_utang_jatuh_tempo_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "mutasi_utang_jatuh_tempo_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end 
  end

  def edit
     @liability = AccountingPurchaseBalance.find(params[:id])
     render :layout => false
  end

  def update
    @liability = AccountingPurchaseBalance.find(params[:id])
    $selected_month, $selected_year = @liability.created_at.strftime("%m"), @liability.created_at.strftime("%Y")
    respond_to do |format|
      if @liability.update_attributes(params[:liability])
        flash[:notice] = 'Utang Jatuh Tempo berhasil di update.'
        format.html { redirect_to(accounting_liability_maturities_path) }
        format.xml  { head :ok }
      else
        flash[:error] = 'Utang Jatuh Tempo gagal di update.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @liability.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  private
  
  def initial_method
    @title = "DAFTAR MUTASI UTANG JATUH TEMPO"
    @periode = true
  end	
end
