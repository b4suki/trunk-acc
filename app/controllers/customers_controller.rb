class CustomersController < ApplicationController
  before_filter :initial_method, :login_required
#  access_control [:new, :create, :update, :edit, :destroy] => 'Inventory | Administrator'
  
  def index
    @customers = Customer.filter_find(
      params[:filter], 
      :all, 
      :order => 'id'
    )
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @customers }
      format.pdf  { 
        send_data render_to_pdf({
            :action => 'index.rpdf',
            :page => 'portrait',
            :size => 'A4',
            :layout => 'pdf_report'
          }), :filename => "daftar_pelanggan.pdf"
      }
      format.xls { render_to_xls(:filename => "daftar_pelanggan.xls") }
    end
  end

  # GET /customers/1
  # GET /customers/1.xml
  def show
    @customer = Customer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @customer }
    end
  end

  # GET /customers/new
  # GET /customers/new.xml
  def new
    @customer = Customer.new
    render :layout => false
  end

  # GET /customers/1/edit
  def edit
    @customer = Customer.find(params[:id])
    render :layout => false
  end

  # POST /customers
  # POST /customers.xml
  def create
    @customer = Customer.new(params[:customer])

    respond_to do |format|
      if @customer.save
        flash[:notice] = 'Data pelanggan berhasil dibuat.'
        format.html { redirect_to(customers_path) }
        format.xml  { render :xml => @customer, :status => :created, :location => @customer }
      else
        flash[:notice] = 'Data pelanggan gagal dibuat.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /customers/1
  # PUT /customers/1.xml
  def update
    @customer = Customer.find(params[:id])

    respond_to do |format|
      if @customer.update_attributes(params[:customer])
        flash[:notice] = 'Data pelanggan berhasil diupdate.'
        format.html { redirect_to(customers_path) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Data pelanggan gagal diupdate.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.xml
  def destroy
    @customer = Customer.find(params[:id])
    
    if @customer.destroy
      flash[:notice] = 'Data pelanggan berhasil dihapus.'
    else
      flash[:notice] = 'Data pelanggan gagal dihapus.'
    end

    respond_to do |format|
      format.html { redirect_to(customers_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def initial_method
    @title = "DAFTAR PELANGGAN"
  end
end
