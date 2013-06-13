class ItemsController < ApplicationController
  before_filter :login_required, :initial_method
  skip_before_filter :verify_authenticity_token,:only => [:auto_complete_for_type_name,:auto_complete_for_unit_name, :show, :auto_complete_for_item_name]

  def index
    @sort = params[:sort]
    conditions = []
    #    conditions << "items.active='1'"
    conditions << "completed ='#{ params[:completed].nil? ? 1 : 0}'"
    conditions << "name LIKE '%#{params[:search]}%'" if params[:search].nil? == false || params[:search] == ""
    conditions = conditions.join(" AND ")
    @completed =  params[:completed].nil? ? 1 : 0
    @items = Item.paginate :page => params[:page], :conditions => conditions, :include => [:type, :unit], :order => @sort

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
      format.pdf  {
        send_data render_to_pdf({
            :action => "index.rpdf",
            :page => 'landscape',
            :size => 'A4',
            :layout => 'pdf_report'
          }), :filename => "list_items.pdf"
      }
      format.xls { render_to_xls(:filename => "list_items.xls") }
    end
  end

  def show
    @title = "DAFTAR KELUAR MASUK BARANG"
    @periode = true
    @item = Item.find(params[:id])

    @items_trans = []
    if request.get? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]
    elsif request.get? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year,
        $selected_month, $selected_year = nil, nil
    elsif request.get? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $month, $year = current_month, current_year
    end

    date = params[:date] ? params[:date] :  {:month => current_month , :year => current_year}
    date = params[:date] ? Time.mktime(params[:date][:year], params[:date][:month], 1, 0, 0, 0, 0) : Time.now
    previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}
    @history_item = ItemHistory.find(:first, :conditions => ["MONTH(last_date) = #{previous_date[:month]} AND YEAR(last_date) = #{previous_date[:year]} AND item_id = '#{@item.id}' "])
    @items_trans = TransItem.find(:all, :conditions => ["MONTH(created_at) = #{$month} AND YEAR(created_at) = #{$year} AND item_id = '#{@item.id}' "], :order => "item_id, created_at asc")

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item }
    end
  end

  def new
    @item = Item.new
    @item.completed = params[:completed]
    render :layout => false
  end

  def edit
    @item = Item.find(params[:id])
    render :layout => false
  end

  def create
    @item = Item.new(params[:item])
    @item.active = params[:active].nil? ? false : true
    respond_to do |format|
      if @item.save
        $month, $year = current_month, current_year
        date = params[:date] ? Time.mktime(current_year, current_month, 1, 0, 0, 0, 0) : Time.now
        previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}
        ItemHistory.create(:item_id => @item.id, :last_date => Time.mktime(previous_date[:year], previous_date[:month], 6, 0, 0, 0, 0), :last_stock => @item.stock,:value =>  @item.total_value)
        flash[:notice] = 'Item berhasil dibuat.'
        format.html { redirect_to(items_path) }
        format.xml  { render :xml => @item, :status => :created, :location => @item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @item = Item.find(params[:id])
    @item.active = params[:active].nil? ? false : true
    respond_to do |format|
      if @item.update_attributes(params[:item])
        flash[:notice] = 'Item berhasil di update.'
        format.html { redirect_to(items_path) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Item gagal di update.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to(items_url) }
      format.xml  { head :ok }
    end
  end

  def auto_complete_for_type_name
    search = params[:type][:name]
    @types = Type.find(:all, :conditions => ["name LIKE ?", "%#{search}%"])
    render :partial => "autocomplete"
  end

  def auto_complete_for_item_name
    search = params[:item][:name]
    @types = Item .find(:all, :conditions => ["name LIKE ?", "%#{search}%"])
    render :partial => "autocomplete"
  end

  def auto_complete_for_unit_name
    search = params[:unit][:name]
    @units = Unit.find(:all, :conditions => ["name LIKE ? ", "%#{search}%"])
    render :partial => "autocomplete_units"
  end

  def show_item_details
    item = Item.find(params[:id])

    render :update do |page|
      if params[:show]
        page.replace_html "item-detail-#{params[:id]}", :partial => "item_detail", :locals => {:item => item, :item_details => item.item_details}
      else
        page.replace_html "item-detail-#{params[:id]}", ""
      end
      page.replace_html "show-hide-item-detail-#{params[:id]}", :partial => "item_detail_trigger", :locals => {:item => item, :show => !params[:show] }
    end
  end

  def history
    @title = "DAFTAR PEMBELIAN PENJUALAN BARANG"
    @periode = true
    item_id, conditions, @data = [],[],{}
    if request.post? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]
    elsif request.post? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year,
        $selected_month, $selected_year = nil, nil
    elsif request.post? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $month, $year = current_month, current_year
    end
    conditions << "MONTH(invoice_date) = #{$month}"
    conditions << "YEAR(invoice_date) = #{$year}"
    conditions = conditions.join(" AND ")
    purchases = AccountingPurchaseBalance.find(:all ,:conditions => conditions, :order => 'created_at')
    sales = AccountingSaleBalance.find(:all ,:conditions => conditions, :order => 'created_at')
    purchases.each { |purchase| item_id << purchase.accounting_purchase_balance_details.collect { |e|   e.item_id }  }
    sales.each { |sale| item_id << sale.accounting_sale_balance_details.collect { |e| e.item_id  }  }
    #    uncompleted_items = Item.find(:all,:conditions => ["MONTH(created_at) = #{$month} AND YEAR(created_at) = #{$year} AND completed = 0 "])
    #    uncompleted_items.each { |uncompleted_item| item_id << uncompleted_item.trans_items.collect { |e | e.item_id}  }
    taking_items = TransItem.find(:all, :conditions => ["MONTH(created_at) = #{$month} AND YEAR(created_at) = #{$year} AND is_addition = false AND purchase_sale_id is NULL"] )
    commodities = Product.find(:all, :conditions => ["MONTH(created_at) = #{$month} AND YEAR(created_at) = #{$year}"])
    item_id = params[:item].nil? ? item_id.uniq.join(",") : params[:item][:id] !='' ? params[:item][:id] : item_id.uniq.join(",")
    if  item_id !=""
      items = Item.find(:all , :conditions => ["id in (#{item_id}) "])
      items.each { |item| @data.update(item.name => []) }
      purchases.each do |purchase|
        purchase.accounting_purchase_balance_details.each do |e|
          @data[e.item.name] << {:date => purchase.invoice_date.strftime("%d-%b-%y"), :qty => e.qty, :price => e.price, :sale => false, :created_at => purchase.updated_at} if !@data[e.item.name].nil?
        end
      end
      sales.each do |sale|
        #        sale.accounting_sale_balance_details.each do |e|
        transaction_sales = TransItem.find(:all, :conditions => ["MONTH(created_at) = #{$month} AND YEAR(created_at) = #{$year} AND is_addition = false AND purchase_sale_id = #{sale.id}"] )
        transaction_sales.each do |e|
          @data[e.item.name] << {:date => sale.invoice_date.strftime("%d-%b-%y"), :qty => e.qty, :price => e.price, :sale => true, :created_at => sale.updated_at} if !@data[e.item.name].nil?
        end
      end
      #      uncompleted_items.each do |uncompleted_item|
      #        uncompleted_item.trans_items.each do |e|
      #          @data[uncompleted_item.name] << {:date => uncompleted_item.created_at.strftime("%d-%b-%y"), :qty => e.qty,:price => e.is_addition ? e.price : uncompleted_item.price, :sale => true, :created_at => e.created_at } if !@data[uncompleted_item.name].nil?
      #        end
      #      end
      commodities.each do |commodity|
        trans_commodities = TransItem.find(:all,:conditions => ["MONTH(created_at) = #{$month} AND YEAR(created_at) = #{$year} AND product_id = #{commodity.id}"])
        trans_commodities.each do |e|
          @data[e.item.name] << {:date => e.created_at.strftime("%d-%b-%y"), :qty => e.qty,:price => e.price, :minus => true, :created_at => e.created_at } if !@data[e.item.name].nil?
        end
      end
      taking_items.each do |taking_item|
        @data[taking_item.item.name] << {:date => taking_item.created_at.strftime("%d-%b-%y"), :qty => taking_item.qty, :price => taking_item.price, :minus => true, :created_at => taking_item.created_at } if !@data[taking_item.item.name].nil?
      end
      date = params[:date] ? params[:date] :  {:month => current_month , :year => current_year}
      date = params[:date] ? Time.mktime(params[:date][:year], params[:date][:month], 1, 0, 0, 0, 0) : Time.now
      previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}
      @history_items = ItemHistory.paginate :page => params[:page], :conditions => ["MONTH(last_date) = #{previous_date[:month]} AND YEAR(last_date) = #{previous_date[:year]} AND item_id in (#{item_id}) "]
      @date = {:month => $month, :year => $year}
      items.each { |item| tmp = ''
        @data[item.name].each_with_index { |x,y|
          if x[:created_at].to_s(:number).to_i < @data[item.name][y+1][:created_at].to_s(:number).to_i
            tmp = @data[item.name][y+1]
            @data[item.name][y+1] = @data[item.name][y]
            @data[item.name][y] = tmp
          end  if !@data[item.name][y+1].nil?
        } }
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
      format.pdf  {
        send_data render_to_pdf({
            :action => "history.rpdf",
            :page => 'landscape',
            :size => 'A4',
            :layout => 'pdf_report'
          }), :filename => "transaksi_barang_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "transaksi_barang_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end
  end

  def edit_detail
    @item_detail = ItemDetail.find(params[:id])
    render :layout => false
  end

  def update_detail
    @item_detail = ItemDetail.find(params[:id])
    @item_detail.total = @item_detail.qty.to_i * params[:item_detail][:price].to_f
    respond_to do |format|
      if @item_detail.update_attributes(params[:item_detail])
        Item.sum_qty_and_total(@item_detail.item_id)
        flash[:notice] = 'Item detail berhasil di update.'
        format.html { redirect_to(items_path) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Item detail gagal di update.'
        format.html { render :action => "edit_detail" }
        format.xml  { render :xml => @item_detail.errors, :status => :unprocessable_entity }
      end
    end
  end

  protected

  def initial_method
    @title = "DAFTAR MASTER BARANG"
  end
end
