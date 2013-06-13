class TransItemStatusesController < ApplicationController
  # GET /trans_item_statuses
  # GET /trans_item_statuses.xml
  def index
    #@trans_item_statuses = TransItemStatus.all
    @trans_item_statuses = TransItemStatus.find(:all, :conditions => ['name LIKE ?', "%#{params[:search]}%"])

#    respond_to do |format|
#      format.js # index.html.erb
#      format.xml  { render :xml => @trans_item_statuses }
#    end
  end

  # GET /trans_item_statuses/1
  # GET /trans_item_statuses/1.xml
  def show
    @trans_item_status = TransItemStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @trans_item_status }
    end
  end

  # GET /trans_item_statuses/new
  # GET /trans_item_statuses/new.xml
  def new
    @trans_item_status = TransItemStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trans_item_status }
    end
  end

  # GET /trans_item_statuses/1/edit
  def edit
    @trans_item_status = TransItemStatus.find(params[:id])
  end

  # POST /trans_item_statuses
  # POST /trans_item_statuses.xml
  def create
    @trans_item_status = TransItemStatus.new(params[:trans_item_status])

    respond_to do |format|
      if @trans_item_status.save
        flash[:notice] = 'TransItemStatus was successfully created.'
        format.html { redirect_to(@trans_item_status) }
        format.xml  { render :xml => @trans_item_status, :status => :created, :location => @trans_item_status }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @trans_item_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /trans_item_statuses/1
  # PUT /trans_item_statuses/1.xml
  def update
    @trans_item_status = TransItemStatus.find(params[:id])

    respond_to do |format|
      if @trans_item_status.update_attributes(params[:trans_item_status])
        flash[:notice] = 'TransItemStatus was successfully updated.'
        format.html { redirect_to(@trans_item_status) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @trans_item_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /trans_item_statuses/1
  # DELETE /trans_item_statuses/1.xml
  def destroy
    @trans_item_status = TransItemStatus.find(params[:id])
    @trans_item_status.destroy

    respond_to do |format|
      format.html { redirect_to(trans_item_statuses_url) }
      format.xml  { head :ok }
    end
  end
end
