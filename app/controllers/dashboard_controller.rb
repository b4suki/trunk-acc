class DashboardController < ApplicationController
  before_filter :login_required
  before_filter :get_role_id
#  access_control [
#     :show_payable_to_customers, :show_payable_to_vendors, :show_receivable_from_customers,
#     :show_receivable_from_vendors, :show_detail_remainders, :edit_remainders, :new_remainder, :create_remainder,
#     :update_div_remainder
#  ] => "Administrator | Direktur | Pembelian | Kas_Bank | Petty_Cash | Inventory | Penjualan"
  #include Ziya
  layout "desktop"

  def index;
      @graph = open_flash_chart_object(420,140,"/dashboard/bar_chart_2")    
  end
  
  def refresh_chart
    chart = Ziya::Charts::Line.new
    render :text => chart
  end

  def show_detail_cash_flow
     @graph = open_flash_chart_object(630,320,"/dashboard/bar_chart_2")
    render :layout => 'application'
  end

  def show_payable_to_customers
##    @customers = AccountingSaleBalance.find(:all, :conditions => ["month(maturity_date) = month(current_date) and year(maturity_date)=year(current_date) and (status_id !=2 or status_id is null) "], :order => 'maturity_date desc')
#    @customer_payables = AccountingSaleBalance.find(:all, :select => "customer_id, SUM(amount_account_payable) AS `sum_of_payable`", :group => "customer_id", :conditions => ["month(maturity_date) = month(current_date) and year(maturity_date)=year(current_date) and (status_id !=2 or status_id is null) "], :order => 'maturity_date desc')
#    render :layout => 'application'

    conditions = []
    conditions << "month(maturity_date) = month(current_date)"
    conditions << "year(maturity_date) = year(current_date)"
    conditions << "(status_id !=2 or status_id is null)"
    conditions = conditions.join(" and ")

    @payables = AccountingSaleBalance.find(:all,
                                           :select => "customer_id, sum(amount_account_payable) as `sum_of_payable`",
                                           :group => :customer_id,
                                           :conditions => conditions,
                                           :having => '`sum_of_payable` > 0',
                                           :order => 'maturity_date desc')
    render :layout => 'application'
  end

  def show_payable_to_vendors
#    @vendors = AccountingPurchaseBalance.find(:all, :conditions => ["month(maturity_date) = month(current_date) and year(maturity_date)=year(current_date) and (status_id !=2 or status_id is null) "], :order => 'maturity_date desc')
    @vendor_payables = AccountingPurchaseBalance.find(:all, :select => "vendor_id, SUM(amount_account_receivable) AS `sum_of_payable` ", :group => "vendor_id", :conditions => ["month(maturity_date) = month(current_date) and year(maturity_date)=year(current_date) and (status_id !=2 or status_id is null) "], :order => 'maturity_date desc')
    render :layout => 'application'
  end

  def show_payables_to_customer
    conditions = []
    conditions << "month(maturity_date) = month(current_date)"
    conditions << "year(maturity_date) = year(current_date)"
    conditions << "(status_id !=2 or status_id is null)"
    conditions = conditions.join(" and ")

    @payables = AccountingSaleBalance.find(:all,
                                           :select => "customer_id, sum(amount_account_payable) as `sum_of_payable`",
                                           :group => :customer_id,
                                           :conditions => conditions,
                                           :having => '`sum_of_payable` > 0',
                                           :order => 'maturity_date desc')
    render :layout => 'application'
  end

  def show_receivable_from_customers
    @customer_receivables = AccountingSaleBalance.find(:all, :select => "customer_id, SUM(amount_account_payable) AS `sum_of_receivable`", :group => "customer_id", :conditions => ["month(maturity_date) = month(current_date) and year(maturity_date)=year(current_date) and (status_id !=2 or status_id is null) "], :order => 'maturity_date desc')
    render :layout => 'application'
  end

  def show_receivable_from_vendors
    @vendor_receivables = AccountingPurchaseBalance.find(:all, :select => "vendor_id, SUM(amount_account_receivable) AS `sum_of_receivable` ", :group => "vendor_id", :conditions => ["month(maturity_date) = month(current_date) and year(maturity_date)=year(current_date) and (status_id !=2 or status_id is null) "], :order => 'maturity_date desc')
    render :layout => 'application'
  end

  def show_detail_remainders        
    if request.post? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]
    elsif request.get? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year
      $selected_month, $selected_year = nil, nil
    elsif request.get? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $month, $year = current_month, current_year
    end
    conditions = []
    conditions << "MONTH(task_date) = MONTH(current_date) and YEAR(task_date) = YEAR(current_date)"
    @remainders = Remainder.find(:all, :conditions => conditions)        
    render :layout => 'application'
  end

  def edit_remainders
    @remainder = Remainder.find(params[:id])
    render :layout => 'application'
  end

  def update
    @remainder = Remainder.find(params[:id]) 
    params[:remainder][:alert_date] = params[:check_aktif].nil? ? nil : params[:remainder_task_date]
    respond_to do |format|
      if @remainder.update_attributes(params[:remainder])
        flash[:notice] = 'Remainder Berhasil Di update.'                
        format.html { redirect_to '/dashboard/show_detail_remainders' }                                
        format.xml  { render :xml => @remainder, :status => :created, :location => @remainder }      
      else
        flash[:notice] = 'Remainder Gagal Di update.'
        format.html { render :action => "new_remainder" }
        format.xml  { render :xml => @remainder.errors, :status => :unprocessable_entity }
      end
    end
  end
          
  def new_remainder
    @remainder = Remainder.new
    render :layout => false
  end
    
  def destroy
    @remainder = Remainder.find(params[:id])
    
    respond_to do |format|
      if @remainder.destroy        
        flash[:notice] = 'Data pelanggan berhasil dihapus.'
        format.html { redirect_to '/dashboard/show_detail_remainders' }                                
        format.xml  { render :xml => @remainder, :status => :created, :location => @remainder }      
      else
        flash[:notice] = 'Data pelanggan gagal dihapus.'
      end
    end   
  end
    
  def create_remainder                
    @remainder = Remainder.new(params[:remainder])
    @remainder.alert_date = params[:check_aktif].nil? ? nil : params[:remainder_task_date]
      
    respond_to do |format|
      if @remainder.save
        flash[:notice] = "Remainder Berhasil Di buat"
        format.html { redirect_to '/dashboard/show_detail_remainders' }                                
        format.xml  { render :xml => @remainder, :status => :created, :location => @remainder }      
      else
        flash[:notice] = "Remainder Gagal Di buat"
      end
    end        
  end     
  
  def update_div_remainder  
    render :update do |page|
      page.replace_html 'box_table_1', :partial => 'remainder'
    end
  end
        

  def graph_code   
    title = Title.new("MultiBar Tooltip")
    
    
    ### bar cash
    bar = Bar.new
    arry = get_value_for_year('CASH')    
    bar.values  = arry
    bar.tooltip = "Cash <br> #val#"
    bar.colour  = '#47092E'    

#    bar2 = Bar.new
#    bar2.set_tooltip("Spoon {#val#}<br>Title Bar 2")
#    bar2.set_colour('#CC2A43')
#
#
#    vals = get_value_for_year('CASH')
#    
#    bar2.values = vals
    
    
    t = Tooltip.new
    t.set_shadow(false)
    t.stroke = 5
    t.colour = '#6E604F'
    t.set_background_colour("#BDB396")
    t.set_title_style("{font-size: 14px; color: #CC2A43;}")
    t.set_body_style("{font-size: 10px; font-weight: bold; color: #000000;}")
    
    x = XAxis.new    
    x.set_labels(['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'])
 


    chart = OpenFlashChart.new
    chart.title = title
    chart.add_element(bar)
    #chart.add_element(bar2)
    chart.set_tooltip(t)
    chart.set_x_axis(x)
    render :text => chart.to_s
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
        p value
      end  
    end  
            
    return value
  end   
  
def bar_chart_2
  ### cash
  bar1 = Bar.new(50, '#0066CC')
  bar1.key('Cash', 10)
  bar1.data = get_value_for_year('CASH').flatten  
  
  ## bank
  bar2 = Bar.new(50, '#9933CC')
  bar2.key('Bank', 10)
  bar2.data = get_value_for_year('BANK').flatten  
  
  ## sales
  bar3 = Bar.new(50, '#639F45')
  bar3.key('Sales', 10)
  bar3.data = get_value_for_year('SALE').flatten  
  
  ## Purchase
  bar4 = Bar.new(50, '#CC2A43')
  bar4.key('Purchase', 10)
  bar4.data = get_value_for_year('PURCHASE').flatten  
  

#  12.times do |t|
#          bar1.data << rand(7) + 3
#          bar2.data << rand(7) + 3
#          bar3.data << rand(7) + 3
#  end
  


  g = Graph.new  
  g.set_bg_color('#FFFFFF')

  g.data_sets << bar1
  g.data_sets << bar2
  g.data_sets << bar3
  g.data_sets << bar4
  
  g.set_x_labels(%w(Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec))
  g.set_x_label_style(10, '#9933CC', 0, 1)
  g.set_x_axis_steps(2)
  g.set_y_max(300000000)  
  g.set_y_label_steps(2) 
  render :text => g.render
end

  
end



