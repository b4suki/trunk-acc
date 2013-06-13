class ServicesController < ApplicationController
  before_filter :login_required, :initial_method
  
  # GET /services
  # GET /services.xml
  def index
    @sort = params[:sort]
    if params[:search].nil? || params[:search] == ""
      @services = Service.paginate :page => params[:page], :order => @sort
    else
      @services = Service.paginate :page => params[:page], :conditions => "name LIKE '%#{params[:search]}%'", :order => @sort
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @services }
      format.pdf  {
        send_data render_to_pdf({
            :action => "index.rpdf",
            :page => 'landscape',
            :size => 'A4',
            :layout => 'pdf_report'
          }), :filename => "list_services.pdf"
      }
      format.xls { render_to_xls(:filename => "list_services.xls") }
    end
  end

  # GET /services/1
  # GET /services/1.xml
  def show
    @service = Service.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @service }
    end
  end

  # GET /services/new
  # GET /services/new.xml
  def new
    @service = Service.new
    render :layout => false
  end

  # GET /services/1/edit
  def edit
    @service = Service.find(params[:id])
    render :layout => false
  end

  # POST /services
  # POST /services.xml
  def create
    @service = Service.new(params[:service])

    respond_to do |format|
      if @service.save
        flash[:notice] = 'Layanan berhasil disimpan'
        format.xml  { render :xml => @service, :status => :created, :location => @service }
      else
        flash[:notice] = 'Layanan gagal disimpan'
        format.xml  { render :xml => @service.errors, :status => :unprocessable_entity }
      end
      format.html { redirect_to(services_path) }
    end
  end

  # PUT /services/1
  # PUT /services/1.xml
  def update
    @service = Service.find(params[:id])

    respond_to do |format|
      if @service.update_attributes(params[:service])
        flash[:notice] = 'Layanan berhasil diupdate'
        format.xml  { head :ok }
      else
        flash[:notice] = 'Layanan gagal diupdate'
        format.xml  { render :xml => @service.errors, :status => :unprocessable_entity }
      end
      format.html { redirect_to(services_path) }
    end
  end

  # DELETE /services/1
  # DELETE /services/1.xml
  def destroy
    @service = Service.find(params[:id])
    @service.destroy

    respond_to do |format|
      format.html { redirect_to(services_url) }
      format.xml  { head :ok }
    end
  end

  private
  def initial_method
    @title = "LAYANAN"
    @periode = false
  end
end
