class Accounting::AdjustmentEntriesController < ApplicationController
  before_filter :initiate_method

  def index
   if request.post? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]
    elsif request.get? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year
      $selected_month, $selected_year = nil, nil
    elsif request.get? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $month, $year = current_month, current_year      
    end
    
    @date = {:month => $month, :year => $year} 
    conditions = []
    conditions << "MONTH(transaction_date) = #{$month}"
    conditions << "YEAR(transaction_date) = #{$year}"
    conditions = conditions.join(" AND ")
    @account_ids = AccountingFixedAssetDetail.find(:all,:conditions => conditions).collect{|a| a.account_id}.uniq   
    @accounts = AccountingAccount.find(:all, :conditions => ["id IN (?)", @account_ids])        
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounts }
      format.pdf  { 
        send_data render_to_pdf({
          :action => 'index.rpdf', 
          :page => 'landscape',
          :size => '30x60cm',
          :layout => 'pdf_report'
        }), :filename => "aktiva_tetap_#{selected_month.downcase}_#{selected_year.downcase}.pdf" 
      }
      format.xls { render_to_xls(:filename => "aktiva_tetap_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end 
  end
  
  def initiate_method
    @title = "Aktiva Tetap"
    @periode = true
  end
  
  def create_aje
    before = false
    if $month == "1"
      $month = "13"
      $year = ($year.to_i - 1).to_s
      before = true
    end 
    conditions = []
    conditions << "MONTH(transaction_date) = #{$month.to_i - 1}"
    conditions << "YEAR(transaction_date) = #{$year}"
    conditions = conditions.join(" AND ")    
    
    @details = AccountingFixedAssetDetail.find(:all,:conditions => conditions)    
    
    respond_to do |format|
      if !@details.blank?
        @details.each do |detail|          
            if AccountingFixedAssetDetail.create(
                :transaction_date => detail.transaction_date.next_month,
                :asset_values => detail.aje_values,
                :depreciation_values => detail.depreciation_values + formula_depreciation(detail),
                :aje_values => detail.aje_values - formula_depreciation(detail),
                :fixed_asset_id => detail.fixed_asset_id,
                :account_id => detail.account_id
              )              
              $selected_month, $selected_year = detail.transaction_date.next_month.strftime("%m"), detail.transaction_date.next_month.strftime("%Y")
               $month, $year = detail.transaction_date.next_month.strftime("%m"), detail.transaction_date.next_month.strftime("%Y") 
            else
              flash[:notice] = "aje gagal dibuat "
            end                              
        end            
      end
      flash[:notice] = "aje berhasil dibuat "
      format.xml  { render :xml => @result, :status => :created, :location => @result }
      format.html { redirect_to(accounting_adjustment_entries_path) }                        
    end
    $month = "1" if before
    $year = ($year.to_i + 1).to_s if before   
  end  
  
  
end
