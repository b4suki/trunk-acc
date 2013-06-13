class VendorsController < ApplicationController
  before_filter :initiate_method, :login_required
  
  def index
    @vendors = Vendor.filter_find params[:filter], :all, :order => 'id'
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @vendors }
      format.pdf  {
        send_data render_to_pdf({
            :action => 'index.rpdf',
            :page => 'portrait',
            :size => 'A4',
            :layout => 'pdf_report'
          }), :filename => "daftar_vendor.pdf"
      }
      format.xls { render_to_xls(:filename => "daftar_vendor.xls") }
    end
  end

  def show
    @vendor = Vendor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @vendor }
    end
  end

  def new
    @vendor = Vendor.new
    render :layout => false
  end

  def edit
    @vendor = Vendor.find(params[:id])
    render :layout => false
  end

  def create
    @vendor = Vendor.new(params[:vendor])

    respond_to do |format|
      if @vendor.save
        flash[:notice] = 'Vendor berhasil dibuat.'
        format.html { redirect_to(vendors_path) }
        format.xml  { render :xml => @vendor, :status => :created, :location => @vendor }
      else
        flash[:notice] = 'Vendor gagal dibuat.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @vendor.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @vendor = Vendor.find(params[:id])

    respond_to do |format|
      if @vendor.update_attributes(params[:vendor])
        flash[:notice] = 'Vendor berhasil diupdate.'
        format.html { redirect_to(vendors_path) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Vendor gagal diupdate.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @vendor.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @vendor = Vendor.find(params[:id])
    if @vendor.destroy
      flash[:notice] = 'Vendor berhasil dihapus.'
    else
      flash[:notice] = 'Vendor gagal dihapus.'
    end

    respond_to do |format|
      format.html { redirect_to(vendors_url) }
      format.xml  { head :ok }
    end
  end
  
  def initiate_method
    @title = "DAFTAR VENDOR"
  end
end
