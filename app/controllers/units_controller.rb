class UnitsController < ApplicationController
  before_filter :initiate_method

  def index
    @units = Unit.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @units }
    end
  end

  # GET /units/1
  # GET /units/1.xml
  def show
    @unit = Unit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @unit }
    end
  end

  # GET /units/new
  # GET /units/new.xml
  def new
    @unit = Unit.new
    render :layout => false
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @unit }
#    end
  end

  # GET /units/1/edit
  def edit
    @unit = Unit.find(params[:id])
    render :layout => false
  end

  # POST /units
  # POST /units.xml
  def create
    @unit = Unit.new(params[:unit])

    respond_to do |format|
      if @unit.save
        flash[:notice] = 'Unit was successfully created.'
        format.html { redirect_to(units_path) }
        format.xml  { render :xml => @unit, :status => :created, :location => @unit }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @unit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /units/1
  # PUT /units/1.xml
  def update
    @unit = Unit.find(params[:id])

    respond_to do |format|
      if @unit.update_attributes(params[:unit])
        flash[:notice] = 'Unit berhasil di update'
        format.html { redirect_to(units_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @unit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.xml
  def destroy
    @unit = Unit.find(params[:id])
    @unit.destroy

    respond_to do |format|
      format.html { redirect_to(units_url) }
      format.xml  { head :ok }
    end
  end

  def initiate_method
    @title = "DAFTAR SATUAN"
  end
end
