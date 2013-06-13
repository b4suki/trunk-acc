class Accounting::ReportsController < ApplicationController
  helper Ziya::Helper
  
  def chart
    
    respond_to do |format|
      format.html
    end
  end
  
  def display_info
    render :update do |page|
      page.replace_html 'info', content_tag("h2", "#{params[:series]}--#{params[:value]}")
    end
  end
  
  def load_chart
    ## TODO: will create dynamic with classify
    ## Dhendy
    chart = Ziya::Charts::Column.new(:license)
    chart.add(:axis_category_text, %w[Jan Feb Mar Apr Mei Jun Jul Ags Sep Okt Nov Des])
    chart.add(:series, "Kas", get_value_for_year('CASH'))
    chart.add(:series, "Bank",get_value_for_year('BANK'))
    chart.add(:series, "Pembelian",get_value_for_year('PURCHASE'))
    chart.add(:series, "Penjualan", get_value_for_year('SALE'))
    chart.add(:theme, "TPMI")
    
    respond_to do |format|
      format.xml { render :xml => chart.to_xml }
    end
  end
  
  def get_value_for_year(option)    
    year =  Time.now.strftime('%Y').to_i
    id_sale = AccountingAccount.find_by_code('11401').accounting_sale_debit_credit.id
    id_purchase = AccountingAccount.find_by_code('21100').accounting_purchase_debit_credit.id
    value = []    
    case option
      
    when "CASH" then
      1.upto(12) do |month|
        value << AccountingCashBalance.accumulate_total_revenue(month,Time.now.strftime('%Y').to_i)        
      end  
    when "BANK" then
      1.upto(12) do |month|
        value << AccountingBankBalance.accumulation_debit(month, Time.now.strftime('%Y').to_i)
      end  
      
    when "SALE" then
      1.upto(12) do |month|        
        value << AccountingSaleDebitCreditValue.get_sum_all_credit_debit(:month => month, :year => year , :debit_credit => id_sale)
      end  
      
    when "PURCHASE" then
      1.upto(12) do |month|        
        value << AccountingPurchaseDebitCreditValue.get_sum_all_credit_debit(:month => month, :year => year, :debit_credit => id_purchase)
      end  
    end  
    
    
    
    return value
  end
    
end