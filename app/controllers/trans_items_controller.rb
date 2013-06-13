class TransItemsController < ApplicationController
  before_filter :initial_method
  skip_before_filter :verify_authenticity_token,:only => [:auto_complete_for_item_name, :auto_complete_for_trans_item_status_name]

  def index
    if request.post? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]
      $stat = params[:status][:items]
    elsif request.get? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year, 
        $selected_month, $selected_year = nil, nil
    elsif request.get? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $month, $year = current_month, current_year
      $stat = nil
    end

    @date = params[:date] ? params[:date] :  {:month => current_month , :year => current_year}
    
    report = params[:report] == "request"? 'index_request.rpdf' : 'index_stock.rpdf'
    filename = params[:report] == "request"? "Purchase_request_#{selected_month.downcase}_#{selected_year.downcase}.pdf" : "Penerimaan Dan Pengeluaran Barang Bulan #{selected_month.downcase} #{selected_year.downcase}"
    conditions = []
    conditions << "MONTH(created_at) = #{$month}"
    conditions << "YEAR(created_at) = #{$year}"
    conditions << "status = '#{$stat}'" if $stat != nil && $stat != ""
    conditions = conditions.join(" AND ")
    
    date = params[:date] ? params[:date] :  {:month => current_month , :year => current_year}
    date = params[:date] ? Time.mktime(params[:date][:year], params[:date][:month], 1, 0, 0, 0, 0) : Time.now
    previous_date = {:month => previous_current_month(date).strftime("%m"), :year => previous_current_month(date).strftime("%Y")}
    @trans_items = TransItem.find(:all, :conditions => conditions, :order => "item_id, created_at desc")
    @purchase_requests = TransItem.find(:all, :conditions => conditions.to_s+" AND status = 'request'")
    @items = Item.find(:all,:limit => 10) 
    @group = TransItem.find(:all, :conditions => "month(trans_items.created_at) = #{$month} and year(trans_items.created_at)= #{$year} and status = 'pegambilan'",:include => :user) # , :group => 'role_id'
    #    @history_item = ItemHistory.find(:all, :conditions => ["MONTH(last_date) = #{previous_date[:month]} AND YEAR(last_date) = #{previous_date[:year]} AND item_id = '#{@items.id}' "])
        
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trans_items }
      format.pdf  {
        send_data render_to_pdf({
            :action => report,
            :page => 'portrait',
            :size => 'A4',
            :fontsize => '8',
            :layout => 'pdf_report'
          }), :filename => filename
      }
      format.xls { render_to_xls(:filename => "Purchase_request_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end
  end

  def show
    @trans_item = TransItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @trans_item }
    end
  end

  def new
    @trans_item = TransItem.new
    @item = Item.find_by_id(params[:id])
   
    render :layout => false
  end

  def edit
    @trans_item = TransItem.find(params[:id])
    render :layout => false
  end

  def create
    status = TransItemStatus.find_or_create_by_name(params[:trans_item][:status_name]) unless params[:trans_item][:status_name].blank?
    @trans_item = TransItem.new(params[:trans_item])
    @trans_item.user_id = current_user.id
    @trans_item.trans_item_status = status
    if params[:trans_item_type]=="Pengambilan"
      @trans_item.is_addition = false
      Item.taking_item(params[:trans_item])
    elsif params[:trans_item_type]=="Penambahan"
      @trans_item.is_addition = true
      item = Item.find(params[:trans_item][:item_id])
      item.item_details << ItemDetail.new(
        :qty => params[:trans_item][:qty],
        :price => item.price,
        :total => params[:trans_item][:qty].to_i * item.price,
        :purchasing_date => Time.now
      )
      item.update_attributes(
        :stock => item.stock.to_i + params[:trans_item][:qty].to_i,
        :total_value => ItemDetail.get_total_value_from_item(item.id)
      )
    end

    respond_to do |format|
      if @trans_item.save
        Item.sum_qty_and_total(@trans_item.item_id)
        if  params[:trans_item][:state] == "withdraw"
          stock.update_attribute(:stock,stock.stock - params[:trans_item][:qty].to_f )
          @trans_item.ambil!
        end
        flash[:notice] = 'Transaksi berhasil dibuat.'
        format.html { redirect_to(items_path) }
        format.xml  { render :xml => @trans_item, :status => :created, :location => @trans_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @trans_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @trans_item = TransItem.find(params[:id])
    if @trans_item.is_addition
      if params[:trans_item][:qty].to_i > @trans_item.qty
        new_stock = @trans_item.item.stock + (params[:trans_item][:qty].to_i - @trans_item.qty)
        @trans_item.item.update_attribute(:stock, new_stock)
      elsif params[:trans_item][:qty].to_i < @trans_item.qty
        new_stock = @trans_item.item.stock - (@trans_item.qty - params[:trans_item][:qty].to_i)
        @trans_item.item.update_attribute(:stock, new_stock)
      end
    else
      if params[:trans_item][:qty].to_i > @trans_item.qty
        new_stock = @trans_item.item.stock - (params[:trans_item][:qty].to_i - @trans_item.qty)
        @trans_item.item.update_attribute(:stock, new_stock)
      elsif params[:trans_item][:qty].to_i < @trans_item.qty
        new_stock = @trans_item.item.stock + (@trans_item.qty - params[:trans_item][:qty].to_i)
        @trans_item.item.update_attribute(:stock, new_stock)
      end
    end

    respond_to do |format|
      if @trans_item.update_attributes(params[:trans_item])
        flash[:notice] = 'Berhasil diupdate'
        format.html { redirect_to(trans_items_path) }
        format.xml  { head :ok }
      else
        format.html { redirect_to(trans_items_path) }
        format.xml  { render :xml => @trans_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /trans_items/1
  # DELETE /trans_items/1.xml
  def destroy    
    @trans_item = TransItem.find(params[:id])
    @trans_item.destroy

    respond_to do |format|
      flash[:notice] = 'Item telah dihapus'
      format.html { redirect_to(trans_items_url) }
      format.xml  { head :ok }
    end
  end

  def destroy_item    
    @trans_item = TransItem.find(params[:id])
    @trans_item.destroy
    $selected_month = params[:month]
    $selected_year = params[:year]
    flash[:notice] = 'item telah dihapus'
    redirect_to :action => :index
  end

  def auto_complete_for_item_name
    search = params[:item][:name]
    @items = Item.find(:all, :conditions => ["name LIKE ? OR name LIKE ? ", "%#{search}%", "%#{search}%"])
    render :partial => "autocomplete"
  end

  def update_status  
    trans = TransItem.find_by_id(params[:id])    
    trans.status == "request"? trans.ready! : trans.cancelready!
  
    render :update do |page|
      page.call "setStatusName", trans.status, trans.id
    end         
  end

  def auto_complete_for_trans_item_status_name
    search = params[:trans_item][:status_name]
    @statuses = TransItemStatus.find(:all, :conditions => ["name LIKE ?", "%#{search}%"])
    render :partial => "autocomplete_statuses"
  end

  private

  def initial_method
    @title = "Transaksi Pengambilan / Penambahan Stok"
    @periode = true
  end

end
