class PulsaCustomersController < ApplicationController
  before_filter :login_required, :initial_method
  skip_before_filter :verify_authenticity_token, :only => [
    :auto_complete_for_customer_name,:auto_complete_for_car_name, 
    :auto_complete_for_item_name, :show_pulsa_details]


  def index
    @setting = PulsaSetting.all
    @pulsa_customers  =PulsaCustomer.paginate :page => params[:page], :order => 'created_at DESC'
  end

  def edit
    @pulsa_customer = PulsaCustomer.find(params[:id])
    render :layout => false
  end

  def new
    @pulsa_customer = PulsaCustomer.new
    @pulsa_customer.date_install = Time.now
    @pulsa_customer.aktif = Time.now
    render :layout => false
  end

  def create
    @pulsa_customer  = PulsaCustomer.new(params[:pulsa_customer])
    #    @pulsa_customer.customer_id = params[:pulsa_customer][:customer_id]
    #    @pulsa_customer.sn = params[:pulsa_customer][:sn]
    #    @pulsa_customer.nopol = params[:pulsa_customer][:nopol]
    #    @pulsa_customer.simcard = params[:pulsa_customer][:simcard]
    @pulsa_customer.date_install = params[:pulsa_customer_date_install]
    @pulsa_customer.aktif = params[:pulsa_customer_aktif]

    if params[:pulsa_customer][:car_id] == ""
      car = Car.create(:name => params[:car][:name])
      @pulsa_customer.car_id = car.id
    
    end

    @pulsa_customer.save
    redirect_to :action => "index"
  end

  def update
    pulsa_customer = PulsaCustomer.find(params[:id])

    pulsa_customer.update_attributes(params[:pulsa_customer] )
    redirect_to :action => "index"
  end

  def destroy
    pulsa_customer = PulsaCustomer.find(params[:id])
    pulsa_customer.destroy

    respond_to do |format|
      format.html { redirect_to(pulsa_customers_path) }
      format.xml  { head :ok }
    end
  end

  def add_pulsa
    @add_pulsa = DetailPulsaCustomer.new
    @add_pulsa.pulsa_customer_id = params[:id]
    render :layout => false
  end

  def create_pulsa
    setting = PulsaSetting.find(:first)
    item = ItemDetail.find(:first, :conditions => "item_id='#{params[:detail][:item_id]}'", :order => "sequence DESC")
    params[:detail][:pulsa] = item.price
    add_pulsa = DetailPulsaCustomer.create(params[:detail])
    pulsa_customer = PulsaCustomer.find(params[:detail][:pulsa_customer_id])
    last_saldo = !pulsa_customer.last_saldo.nil? ?  item.price + pulsa_customer.last_saldo : item.price
    pulsa_customer.update_attribute('last_saldo', last_saldo )
    item.update_attribute("qty", item.qty.to_i - params[:detail][:pulsa].to_i)
    redirect_to :action => "index"
  end

  def show_pulsa_details
    pulsa = PulsaCustomer.find(params[:id])
    conditions = []
    conditions << "MONTH(date_pulsa)=#{current_month}"
    conditions << "YEAR(date_pulsa)=#{current_year}"
    conditions = conditions.join(" AND ")
    render :update do |page|
      if params[:show]
        page.replace_html "pulsa-detail-#{params[:id]}", :partial => "pulsa_detail", :locals => {:pulsa_customer => pulsa, :pulsa_details => pulsa.detail_pulsa_customers.find(:all, :conditions => conditions)}
      else
        page.replace_html "pulsa-detail-#{params[:id]}", ""
      end
      page.replace_html "show-hide-pulsa-detail-#{params[:id]}", :partial => "pulsa_detail_trigger", :locals => {:pulsa_customer => pulsa, :show => !params[:show] }
    end
  end

  def show_payment_details
    pulsa = PulsaCustomer.find(params[:id])
    render :update do |page|
      if params[:show]
        page.replace_html "pulsa-detail-#{params[:id]}", :partial => "payment_date", :locals => {:pulsa_customer => pulsa, :payment_details => pulsa.pulsa_customer_payment_dates.find(:all, :conditions => ['pulsa_customer_id = ?', pulsa.id]), :payment_remain => pulsa.pulsa_customer_payment_dates.find(:first,:select => "count(*) as payment_count", :conditions => ["pulsa_customer_id = ? and payment_status = ?",pulsa.id,false]) }
      else
        page.replace_html "pulsa-detail-#{params[:id]}", ""
      end
      page.replace_html "show-hide-payment-detail-#{params[:id]}", :partial => "payment_detail_trigger", :locals => {:pulsa_customer => pulsa, :show => !params[:show] }
    end
  end
  def edit_saldo
    @pulsa = PulsaCustomer.find(params[:id])
    render :layout => false
  end

  def update_last_saldo
    pulsa = PulsaCustomer.find(params[:id])
    pulsa.update_attribute('last_saldo', params[:last_saldo] )
    redirect_to :action => "index"
  end

  def auto_complete_for_customer_name
    search = params[:customer][:name]
    @customers = Customer.find(:all, :conditions => ["name LIKE ? ", "%#{search}%"])
    render :partial => "list_customer"
  end

  def auto_complete_for_car_name
    search = params[:car][:name]
    @cars = Car.find(:all, :conditions => ["name LIKE ? ", "%#{search}%"])
    render :partial => "list_car"
  end

  def auto_complete_for_item_name
    search = params[:item][:name]
    @items = Item.find(:all, :conditions => ["name LIKE ? AND completed ='1'", "%#{search}%"])
    render :partial => "list_item"
  end

  def update_payment_status
    payment = PulsaCustomerPaymentDate.find(params[:id])
    payment_remain = PulsaCustomerPaymentDate.find(:first,:select => "count(*) as payment_count", :conditions => ["pulsa_customer_id = ? and payment_status = ?",payment.id,false])
    payment_div_id = "payment_status_#{params[:id]}"
    payment_remain_div_id = "payment_remain_#{payment.pulsa_customer_id}"
    render :update do |page|
      if payment.update_attribute(:payment_status, true)
        page[payment_div_id.to_sym].update "#{payment.payment_status}"
        page[payment_remain_div_id.to_sym].update "Daftar Angsuran (#{payment.pulsa_customer.package}x Angsuran) - Sisa Pembayaran : #{payment_remain.payment_count}"
      end
    end
  end
  
  private

  def initial_method
    @title = "DAFTAR ISI PULSA CUSTOMER"
  end


end
