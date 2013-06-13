class ProductsController < ApplicationController
  before_filter :login_required, :initial_method
  skip_before_filter :verify_authenticity_token,:only => [:auto_complete_for_prototype_item_name,
    :auto_complete_for_type_name,:auto_complete_for_unit_name,:add_barang,
    :multi_auto_complete_for_detail_product_name, :get_prototype_item_details]

  def index

    @sort = params[:sort]
    conditions = []
    conditions << "items.active='1'"
    conditions << "completed='0'"
    conditions << "name LIKE '%#{params[:search]}%'" if params[:search].nil? == false || params[:search] == ""
    conditions = conditions.join(" AND ")
    @items = Item.paginate :page => params[:page], :conditions => conditions, :include => [:type, :unit], :order => @sort
    #
    #    @sort = params[:sort]
    #    conditions = []
    #    conditions << "active='1'"
    #    conditions << "name LIKE '%#{params[:search]}%'" if params[:search].nil? == false || params[:search] == ""
    #    conditions = conditions.join(" AND ")
    #    @completed_cheack = params[:completed]
    #    @products = Product.paginate :page => params[:page], :conditions => conditions, :order => @sort

    #    respond_to do |format|
    #      format.html # index.html.erb
    #      format.xml  { render :xml => @items }
    #      format.pdf  {
    #        send_data render_to_pdf({
    #            :action => "index.rpdf",
    #            :page => 'landscape',
    #            :size => 'A4',
    #            :layout => 'pdf_report'
    #          }), :filename => "list_products.pdf"
    #      }
    #      format.xls { render_to_xls(:filename => "list_products.xls") }
    #    end
  end

  def show
    @product = Product.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @product }
    end
  end

  def new
    @product = Product.new
    @prototype_item = PrototypeItem.find_by_item_id(params[:item])
    @index = @prototype_item.prototype_item_details.size
    render :layout => false
  end

  def edit
    @product = Product.find(params[:id])
    @prototype_item = PrototypeItem.find_by_item_id(@product.item_id)
    @index = @prototype_item.prototype_item_details.size
    render :layout => false
  end

  def create
    status = TransItemStatus.find_or_create_by_name("Pembuatan Alat")
    prototype = PrototypeItem.find(params[:product][:prototype_item_id])
    @product = Product.new(params[:product])
    @product.active = params[:active].nil? ? false : true
    @product.status = false
    loop = params[:count].nil? ? 0 : params[:count].to_i
    loop = 0 if params[:count].to_i < 0
    0.upto(loop) do |i|
      detail = ProductDetail.new
      if params["product_id_#{i}"] != nil
        detail.item_id =  params["product_id_#{i}"]
        detail.quntity = params["detail_qty_#{i}"]
        @product.product_details << detail
        item_detail = ItemDetail.find(:first, :conditions => "item_id='#{params["product_id_#{i}"]}'", :order => "sequence DESC")
        trans_item = TransItem.new
        trans_item.item_id = params["product_id_#{i}"]
        trans_item.user_id = current_user.id
        trans_item.qty = params["detail_qty_#{i}"]
        trans_item.is_addition = false
        trans_item.description = "Pembuatan alat untuk #{prototype.item.name}"
        trans_item.date_buy = item_detail.purchasing_date rescue nil
        trans_item.price = item_detail.price rescue nil
        trans_item.sequence = item_detail.sequence rescue nil
        trans_item.trans_item_status = !status.nil? ? status : 'Pembuatan Alat'
        item = Item.find(params["product_id_#{i}"])
        item.update_attribute("stock", item.stock.to_i - params["detail_qty_#{i}"].to_i)
        @product.trans_items << trans_item
      end
    end
    
    respond_to do |format|
      if @product.save
        flash[:notice] = 'Product berhasil dibuat.'
        format.html { redirect_to(products_path) }
        format.xml  { render :xml => @product, :status => :created, :location => @product }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @product = Product.find(params[:id])
    trans_item = TransItem.find_all_by_product_id(params[:id])
    @product.active = params[:active].nil? ? false : true
    @product.status = false
    @product.product_details.each { |detail| detail.destroy }
    @product.trans_items.each { |detail|
      conditions = []
      conditions << "item_id='%#{detail.item_id}'"
      conditions << "purchasing_date='%#{detail.date_buy}'"
      conditions << "sequence = '%#{detail.sequence}' "
      conditions  = conditions.join(" AND ")
      item_detail = ItemDetail.find(:first, :conditions => conditions)
      if !item_detail.nil?
        item_detail.update_attributes(:qty => item_detail.qty  +  detail.qty.to_i,
          :total => (item_detail.qty  +  detail.qty.to_i) * detail.price)
      else
        ItemDetail.create(:qty => detail.qty ,
          :price => detail.price, :total => (detail.price * detail.qty.to_i),
          :purchasing_date => detail.date_buy, :created_at => detail.date_buy,
          :updated_at => detail.date_buy, :sequence => detail.sequence
        )
      end
    }
    @product.trans_items.each { |detail| detail.destroy }

    loop = params[:count].nil? ? 0 : params[:count].to_i
    loop = 0 if params[:count].to_i < 0
    0.upto(loop) do |i|
      detail = ProductDetail.new
      if params["product_id_#{i}"] != nil
        detail.item_id =  params["product_id_#{i}"]
        detail.quntity = params["detail_qty_#{i}"]
        @product.product_details << detail
        item_detail = ItemDetail.find_last_by_item_id(params["product_id_#{i}"])
        item = Item.find(params["product_id_#{i}"])
        trans_item = TransItem.new

        trans_item.item_id = params["product_id_#{i}"]
        trans_item.user_id = current_user.id
        trans_item.qty = params["detail_qty_#{i}"]
        trans_item.is_addition = false
        trans_item.description = " Pembuatan alat untuk #{@product.item.name}"
        trans_item.date_buy = item_detail.created_at
        trans_item.price = item_detail.price
        item.update_attribute("stock", item.stock.to_i - params["detail_qty_#{i}"].to_i)
        @product.trans_items << trans_item
      end
    end

    respond_to do |format|
      if @product.update_attributes(params[:product])
        flash[:notice] = 'Product berhasil di update.'
        format.html { redirect_to(products_path) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Product gagal di update.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to(products_url) }
      format.xml  { head :ok }
    end
  end

  def auto_complete_for_type_name
    search = params[:type][:name]
    @types = Type.find(:all, :conditions => ["name LIKE ?", "%#{search}%"])
    render :partial => "autocomplete"
  end

  def auto_complete_for_unit_name
    search = params[:unit][:name]
    @units = Unit.find(:all, :conditions => ["name LIKE ? ", "%#{search}%"])
    render :partial => "autocomplete_units"
  end

  def show_product_details
    conditions = []
    conditions << "item_id = #{params[:id]}"
    conditions << "status = 'false'"
    conditions = conditions.join(" AND ")
    product = Product.find(:all, :conditions => conditions , :order => 'created_at')

    
    render :update do |page|
      if params[:show]
        page.replace_html "product-detail-#{params[:id]}", :partial => "item_detail", :locals => {:item => product, :product => product}
      else
        page.replace_html "product-detail-#{params[:id]}", ""
      end
      page.replace_html "show-hide-product-detail-#{params[:id]}", :partial => "item_detail_trigger", :locals => {:item_id => params[:id], :show => !params[:show] }
    end
  end

  def auto_complete_for_prototype_item_name
    search = params[:prototype_item][:name]
    @prototype_items = PrototypeItem.find(:all, :conditions => ["name LIKE ?", "%#{search}%"])
    render :partial => "autocomplete_prototype"
  end

  #    def add_barang
  #      render :update do |page|
  #        page.insert_html :before, "detail_item",
  #          :partial => 'detail_item',
  #          :object => PrototypeItemDetail.new,
  #          :locals => {:index => params[:index]}
  #        page.replace_html "link_add", :partial => "add_new_link", :locals => {:index => params[:index]}
  #        page.call "setIndex", 1,'count'
  #      end
  #    end
  #
  #    def multi_auto_complete_for_detail_product_name
  #      search = params["detail_product_name_#{params[:index]}"]
  #      products = Item.find(:all, :conditions => ["name LIKE ?", "%#{search}%"])
  #      render :partial => "shared/autocomplete_product", :locals => {:products => products}
  #    end

  def get_prototype_item_details
    @prototype_item_details = PrototypeItemDetail.find_all_by_prototype_item_id(params[:prototype_item_id],
      :select => "prototype_item_details.id, prototype_item_details.item_id, prototype_item_details.quantity, items.name 'item_name'",
      :joins => :item, :order => "items.name")
    render :update do |page|
      page << "clear_new_item_details();"
      page.insert_html :before, "detail_item", :partial => 'detail_item_2'
      page << "recalc_qty_item_details();"
      page.call "setIndex",@prototype_item_details.size,'count'
    end
  end

  def input_price
    #    p params[:id]
    item = Product.find(params[:id])
    @product_id = item.id
    @item_detail = ItemDetail.new
    @item_detail.item_id = item.item_id
    @item_detail.qty = item.quantity
    @item_detail.purchasing_date = Time.now
    #    @item_detail.total = Time.now
    render :layout => false
  end

  def save_price
    product = Product.find(params[:product][:product_id])
    item_detail = ItemDetail.new(params[:item_detail])
    item_detail.total = item_detail.qty.to_f * item_detail.price.to_f

    respond_to do |format|
      if product.update_attribute(:status, true) && item_detail.save
        flash[:notice] = "Item Berhasil Dibuat"
        format.html {redirect_to :action => :index}
      else
        flash[:notice] = "Item Gagal Dibuat"
        format.html {redirect_to :action => :index}
      end
    end
  end
  
  protected

  def initial_method
    @title = "DAFTAR MASTER BARANG"
  end
end
