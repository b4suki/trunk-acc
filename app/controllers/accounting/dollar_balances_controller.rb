class Accounting::DollarBalancesController < ApplicationController
#  access_control [:index, :new, :edit, :create, :update, :destroy,
#    :saldo_new,:create_new_saldo
#  ] => "Administrator | Kas_Bank  & (!Inventory)"
  before_filter :initial_method

  def index
    if request.post? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]
    elsif request.get? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year,
        $selected_month, $selected_year = nil, nil
    elsif request.get? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $month, $year = current_month, current_year
    end

    filename = "transaksi_kas_dollar_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
    conditions = []
    conditions << "MONTH(transaction_date) = #{$month}"
    conditions << "YEAR(transaction_date) = #{$year}"
    conditions = conditions.join(" AND ")

    @dollar_balances = AccountingDollarBalance.find(:all, :conditions => conditions, :order => :transaction_date)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dollar_balances }
      format.pdf  {
        send_data render_to_pdf({
            :action => "index.rpdf",
            :page => 'portrait',
            :size => 'A4',
            :fontsize => '8',
            :layout => 'pdf_report'
          }), :filename => filename
      }
      format.xls { render_to_xls(:filename => "transaksi_kas_dollar_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end
  end

  def new
    @dollar_balance = AccountingDollarBalance.new
    render :layout => false
  end

  def create
    @dollar_balance = AccountingDollarBalance.new(params[:dollar_balance])
    @dollar_balance.total_revenue = 0 if params[:dollar_balance][:total_revenue].nil?
    @dollar_balance.total_payment = 0 if params[:dollar_balance][:total_payment].nil?
    @dollar_balance.dollar_balance = 0 if params[:dollar_balance][:dollar_balance].nil?

    #    $selected_month, $selected_year = @cash_balance.created_at.strftime("%m"), @cash_balance.created_at.strftime("%Y")
    respond_to do |format|
      if @dollar_balance.save
        flash[:notice] = 'Transaksi berhasil dibuat.'
        format.html { redirect_to(accounting_dollar_balances_path) }
        format.xml  { render :xml => @dollar_balance, :status => :created, :location => @dollar_balance }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dollar_balance.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @dollar_balance = AccountingDollarBalance.find(params[:id])
    render :layout => false
  end

  def update
    @dollar_balance = AccountingDollarBalance.find(params[:id])

    respond_to do |format|
      if @dollar_balance.update_attributes(params[:dollar_balance])
        flash[:notice] = 'Transaksi berhasil diupdate.'
        format.html { redirect_to(accounting_dollar_balances_path) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Transaksi gagal diupdate.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dollar_balance.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @dollar_balance = AccountingDollarBalance.find(params[:id])
    if @dollar_balance.destroy
      flash[:notice] = 'Transaksi berhasil dihapus.'
    else
      flash[:notice] = 'Transaksi gagal dihapus.'
    end

    respond_to do |format|
      format.html { redirect_to(accounting_dollar_balances_path) }
      format.xml  { head :ok }
    end
  end
  def saldo_new
    @dollar_balance = AccountingDollarBalance.new
    render :layout => false
  end

  def create_new_saldo
    created_time = Time.mktime( params[:date][:year].to_i, params[:date][:month].to_i, 1, 0, 0, 0, 0 )
    x = AccountingDollarBalance.create(
      :description => "Data Saldo Awal",
      :transaction_date => created_time.strftime("%Y-%m-%d 00:00:00"),
      :total_revenue => params[:saldo],
      :dollar_balance => params[:saldo],
      :kurs => params[:kurs],
      :without_calculation => true
    )
    respond_to do |format|
      format.html { redirect_to(accounting_dollar_balances_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  def initial_method
    @title = "Transaksi Kas Mata Uang Dollar"
    @periode = true
  end
end
