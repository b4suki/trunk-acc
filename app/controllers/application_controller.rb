# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper Ziya::Helper
  include AuthenticatedSystem
  #include DesktopHelper
 
  #
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '19ef53b39db1f8e1f72bc1a89a702346'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  def is_admin?
    current_user && current_user.roles.first && current_user.roles.first.title == "Administrator" ? true : false    
  end

  helper_method :is_admin?

  protected
  
  def permission_denied
    #flash[:notice] = "Kamu Tidak Punya Hak Untuk Mengakses."
    return redirect_to(new_session_path)
  end

  def permission_granted
    #flash[:notice] = "Welcome to the secure area of foo.com!"
  end
      
#  def get_parent_code(parent)
#    parent = AccountingAccount.find(parent)
#    parent ? parent.code_a : ""
#  end
#    
# helper_method :get_parent_code

  
  def current_date
    now = Time.now
    now.strftime("%d")
  end
  
  def current_month
    now = Time.now
    now.strftime("%m")
  end
  
  def previous_current_month(date)
    date.beginning_of_month.months_ago(1) 
  end
  
  def current_year
    now = Time.now
    now.strftime("%Y")
  end 
  
  def month_names(index)
    month = ["JANUARI", "FEBRUARI", "MARET", "APRIL", "MEI", "JUNI", "JULI", "AGUSTUS", "SEPTEMBER", "OKTOBER", "NOVEMBER", "DESEMBER"]
    return month[index.to_i - 1]
  end
  
  def month_index(name)
    month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    return month.index(name)+1
  end
 
  def set_access_control
    controller_name = params[:controller].split("/")[-1]
    role = current_user.roles.first
    action = []
    modul = Modul.find_by_controller_name(controller_name)
    if modul && role
      role.rules.each do |rule|
        action << rule.action.action_name.to_sym if rule.modul_id == modul.id
      end
    end
    action
  end
  
  def get_role_id
    role = current_user.roles.first
    @role = role ? role.id : nil
  end
  
  def check_fixed_assets(id_account)          
     AdjustmentAccount.find(:first, :conditions => ["account_id = ?", id_account]) ? true : false     
  end
  
  def render_to_pdf(options = nil)
    data = render_to_string(options)
    pdf = PDF::HTMLDoc.new
    pdf.set_option :bodycolor, :white
    pdf.set_option :toc, false
    pdf.set_option options[:page] ? options[:page].to_sym : :portrait, true
    pdf.set_option :links, false
    pdf.set_option :webpage, true
    pdf.set_option :left, '2cm'
    pdf.set_option :right, '2cm'
    pdf.set_option :size, options[:size] || 'A4'
    pdf << data
    pdf.generate
  end
  
  def render_to_xls(options = nil)
    headers['Content-Type'] = "application/vnd.ms-excel"
    headers['Content-Disposition'] = "filename=#{options[:filename]}"
    render :layout => 'xls_report'
  end
  
  def selected_month
    if $month
      case $month.to_i
        when 1 then "Januari"
        when 2 then "Februari"
        when 3 then "Maret"
        when 4 then "April"
        when 5 then "Mei"
        when 6 then "Juni"
        when 7 then "Juli"
        when 8 then "Agustus"
        when 9 then "September"
        when 10 then "Oktober"
        when 11 then "November"
        when 12 then "Desember"
      end
    else
      Time.now.strftime("%B")
    end
  end
  
  def selected_export_month(month)    
      case month.to_i
        when 1 then "Januari"
        when 2 then "Februari"
        when 3 then "Maret"
        when 4 then "April"
        when 5 then "Mei"
        when 6 then "Juni"
        when 7 then "Juli"
        when 8 then "Agustus"
        when 9 then "September"
        when 10 then "Oktober"
        when 11 then "November"
        when 12 then "Desember"
      end
    end
    
  def validate_account
    acc = []    
      AccountingAccount.find(:all).each do |p|        
       acc << "#{p.code}   #{p.description}"              
      end
    return acc
  end

  def validate_customer
    customers = []
    Customer.find(:all).each do |customer|
      customers << customer.name
    end
    return customers
  end

  def validate_item
    items = []
      Item.find(:all).each do |it|
       items << "#{it.id}   #{it.name}"
      end
    return items
  end

  def validate_invoice_number(month, year)
    invoice_number = []
    AccountingPurchaseBalance.find(:all, :conditions => ["month(invoice_date) = ? and year(invoice_date) = ?", month, year]).each do |p|
      invoice_number = p.invoice_number
    end    
    return invoice_number
  end
    
  def selected_year
    $year ? $year : Time.now.strftime("%Y")
  end
  
        
  def get_total_field
    $FIELD = {}
    $FIELD = {
      :discount => 0, :subtotal => 0, :transaction_value => 0,
      :ppn_value => 0, :shipping_cost => 0,
      :cash_account => 0,  :payment_value => 0
    }
  end
  
  def set_total_field_for(obj, field)
    $FIELD[field] += obj.send(field)
  end
  
  def show_total_for(field)         
     $FIELD[field]
  end
  
  def format_currency_total(number)    
    toggle_value = nil
    toggle_value = (number * -1) if number < 0
    value = number_to_currency(toggle_value || number, :unit => "", :delimiter => ",", :separator => ".", :precision => 2)
    if toggle_value
      "<font color='red'>(#{value})</font>"
    else
      value
    end
  end
  
  def formula_depreciation(details)
    ((details.accounting_fixed_asset.value - details.accounting_fixed_asset.scrap_value) *(1.to_f/details.accounting_fixed_asset.valuable_age.to_f))*0.083333
  end
  
  def formula_depreciation_reverse(detail, status)      
    bol = false
    values = 0
    conditions = []
    cek =  AdjustmentAccount.find(:first, :conditions => ['account_id = ?', detail.account_id])
    bol = cek.debit_credit
    if status
      conditions << "month(transaction_date) = #{$month}"
      conditions << "Year(transaction_date) = #{$year}"
      conditions << "fixed_asset_id = #{detail.fixed_asset_id}"
      conditions << "account_id = #{detail.account_id}"
      conditions = conditions.join(' AND ')
    end  
        
    fixedDetails = AccountingFixedAssetDetail.find(:all, :conditions => conditions)      
    fixedDetails.each do |fixed|
      if fixed.transaction_date != $month  || fixed.transaction_date.strftime('%d') <= "15" 
        values += ((fixed.accounting_fixed_asset.value - fixed.accounting_fixed_asset.scrap_value) *(1.to_f/fixed.accounting_fixed_asset.valuable_age.to_f))*0.083333            
      end
    end  
    x_values = ""       
    if bol == true
      $TOTAL_FIXED_ASSETS_CREDIT = $TOTAL_FIXED_ASSETS_CREDIT + values
     x_values << "<td>&nbsp;</td>"     
     x_values << "<td>#{values}</td>"
     #x_values << "<td>&nbsp;</td>"
     #x_values << "<td>&nbsp;</td>"
    else           
     #$TOTAL_FIXED_ASSETS_DEBIT = $TOTAL_FIXED_ASSETS_DEBIT + values
     x_values << "<td>#{values}</td>"
     x_values << "<td>&nbsp;</td>"     
     #x_values << "<td>&nbsp;</td>"
     #x_values << "<td>&nbsp;</td>"
    end
    x_values
  end
  
   def check_month_before_create(obj)  
    before = false
    if $month == "1"
       $month = "13"
       $year = ($year.to_i - 1).to_s
       before = true
    end 
    conditions = []
    conditions << "month(transaction_date) = #{$month.to_i - 1}"
    conditions << "Year(transaction_date) = #{$year}"
    conditions << "fixed_asset_id = #{obj.fixed_asset_id}"
    conditions = conditions.join(" and ")     
    $month = "1" if before
    $year = ($year.to_i + 1).to_s if before     
    AccountingFixedAssetDetail.find(:all, :conditions => conditions).blank? ? false : true
  end
  
  def month_names_before(index)       
    if index == "1" || index == "13"
      index = "12" 
    end
    month = ["JANUARI", "FEBRUARI", "MARET", "APRIL", "MEI", "JUNI", "JULI", "AGUSTUS", "SEPTEMBER", "OKTOBER", "NOVEMBER", "DESEMBER"]
    return month[index.to_i - 1]
  end
  
  def get_id_adjusment(account_id)
    value = nil
    x = AdjustmentAccount.find(:first, :conditions =>['account_id = ?',account_id])
    value = x.id
  end

  def create_sale_debit_credit_value(sale_debit_credit_id, value, total_value, created_at)
    sale_debit_credit_value = AccountingSaleDebitCreditValue.new(
      :sale_debit_credit_id => sale_debit_credit_id,
      :value => value,
      :total_value => total_value,
      :created_at => created_at
    )
    return sale_debit_credit_value
  end

  def get_as_adjusted_saldo(account, period)
    as_adjusted_saldo = account.trial_balances.find(
      :first,
      :conditions => ["MONTH(transaction_date)=#{period[:month]} AND YEAR(transaction_date)=#{period[:year]}"]
    )
    as_adjusted_saldo = as_adjusted_saldo.nil? ? 0 : as_adjusted_saldo.as_adjusted
  end

  helper_method :current_date, :current_month, :current_year, :month_names, 
    :month_index, :selected_month, :selected_year, :selected_export_month, :validate_account, :set_total_field_for, :show_total_for,
    :formula_depreciation,:check_month_before_create,  :month_names_before, :formula_depreciation_reverse, :get_id_adjusment, :validate_invoice_number,
    :format_currency_total, :validate_customer, :get_as_adjusted_saldo
end
