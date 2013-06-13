class PrototypeItemsController < ApplicationController
  before_filter :login_required, :initial_method
  skip_before_filter :verify_authenticity_token, :only => [
    :multi_auto_complete_for_detail_product_name,
    :show_item_details,
    :auto_complete_for_item_name
  ]
  def index
    @sort = params[:sort]
    conditions = []
    conditions << "active='1'"
    conditions << "name LIKE '%#{params[:search]}%'" if params[:search].nil? == false || params[:search] == ""
    conditions = conditions.join(" AND ")

    @products = PrototypeItem.paginate :page => params[:page], :conditions => conditions, :order => @sort
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
    end
  end

  def show
    @product = PrototypeItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item }
    end
  end

  def new
    @index = -1
    @product = PrototypeItem.new
    render :layout => false
  end

  def edit
    @product = PrototypeItem.find(params[:id])
    @index = @product.prototype_item_details.size
    render :layout => false
  end

  def create
    @product = PrototypeItem.new(params[:prototype_item])
    @product.active = params[:active].nil? ? false : true
    loop = params[:count].nil? ? 0 : params[:count].to_i
    loop = 0 if params[:count].to_i < 0
    0.upto(loop) do |i|
      detail = PrototypeItemDetail.new
      if params["product_id_#{i}"] != nil
        detail.item_id =  params["product_id_#{i}"]
        detail.quantity = params["detail_qty_#{i}"]
        @product.prototype_item_details << detail
      end
    end
    respond_to do |format|
      if @product.save
        flash[:notice] = 'Prototype Barang Berhasil Dibuat'
       
        format.html { redirect_to(prototype_items_path) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Prototype Barang gagal dibuat'
        format.html { render :action => "new" }
        format.xml  { render :xml => @sale_balance.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @product = PrototypeItem.find(params[:id])
    @product.prototype_item_details.each { |detail| detail.destroy }
    @product.active = params[:active].nil? ? false : true
    loop = params[:count].nil? ? 0 : params[:count].to_i
    loop = 0 if params[:count].to_i < 0
    0.upto(loop) do |i|
      detail = PrototypeItemDetail.new
      if params["product_id_#{i}"] != nil
        detail.item_id =  params["product_id_#{i}"]
        detail.quantity = params["detail_qty_#{i}"]
        @product.prototype_item_details << detail
      end
    end
    respond_to do |format|
      if @product.update_attributes(params[:prototype_item])
        flash[:notice] = 'Prototype Barang Berhasil Dibuat'

        format.html { redirect_to(prototype_items_path) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Prototype Barang gagal dibuat'
        format.html { render :action => "new" }
        format.xml  { render :xml => @sale_balance.errors, :status => :unprocessable_entity }
      end
    end
  end

  def auto_complete_for_item_name
    search = params[:item][:name]
    @items = Item.find(:all, :conditions => ["name LIKE ? AND completed = 0 ", "%#{search}%"])
    render :partial => "autocomplete"
  end

  def destroy
    @item = PrototypeItem.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to(prototype_items_url) }
      format.xml  { head :ok }
    end
  end
  
  def add_barang
    render :update do |page|
      page.insert_html :before, "detail_item",
        :partial => 'detail_item',
        :object => PrototypeItemDetail.new,
        :locals => {:index => params[:index]}
      page.replace_html "link_add", :partial => "add_new_link", :locals => {:index => params[:index]}
      page.call "setIndex", 1,'count'
    end
  end

  def multi_auto_complete_for_detail_product_name
    search = params["detail_product_name_#{params[:index]}"]
    products = Item.find(:all, :conditions => ["name LIKE ? AND completed = 1 ", "%#{search}%"])
    render :partial => "shared/autocomplete_product", :locals => {:products => products}
  end

  def show_item_details
    item = PrototypeItem.find(params[:id])

    render :update do |page|
      if params[:show]
        page.replace_html "product-detail-#{params[:id]}", :partial => "item_detail", :locals => {:product => item, :item_details => item.prototype_item_details}
      else
        page.replace_html "product-detail-#{params[:id]}", ""
      end
      page.replace_html "show-hide-product-detail-#{params[:id]}", :partial => "item_detail_trigger", :locals => {:product=> item, :show => !params[:show] }
    end
  end


  protected

  def initial_method
    @title = "DAFTAR MASTER PROTOTYPE BARANG"
  end

end
