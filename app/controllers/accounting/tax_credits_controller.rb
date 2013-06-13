class Accounting::TaxCreditsController < ApplicationController
  before_filter :initial_method, :login_required
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_vendor_name,:auto_complete_for_customer_name]

  def index
    if request.post? && params[:date]
      $month, $year = params[:date][:month], params[:date][:year]
    elsif request.get? && $selected_month && $selected_year
      $month, $year = $selected_month, $selected_year
      $selected_month, $selected_year = nil, nil
    elsif request.get? && params[:format].nil? && $selected_month.nil? && $selected_year.nil?
      $month, $year = current_month, current_year
    end

    conditions = []
    conditions << "MONTH(ssp_date)=#{$month}"
    conditions << "YEAR(ssp_date)=#{$year}"
    conditions = conditions.join(" AND ")

    @tax_credits = TaxCredit.paginate :page => params[:page], :conditions => conditions

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tax_credits }
      format.pdf  {
        send_data render_to_pdf({
            :action => 'index.rpdf',
            :page => 'landscape',
            :size => '30x60cm',
            :layout => 'pdf_report'
          }), :filename => "kredit_pajak_#{selected_month.downcase}_#{selected_year.downcase}.pdf"
      }
      format.xls { render_to_xls(:filename => "kredit_pajak_#{selected_month.downcase}_#{selected_year.downcase}.xls") }
    end
  end

  def new
    @tax_credit = TaxCredit.new
    render :layout => false
  end

  def create
    @tax_credit = TaxCredit.new(params[:tax_credit])

    if @tax_credit.save
      flash[:notice] = "Kredit pajak berhasil disimpan"
    else
      flash[:notice] = "Kredit pajak gagal disimpan"
    end
    redirect_to accounting_tax_credits_path
  end

  def edit
    @tax_credit = TaxCredit.find(params[:id])
    render :layout => false
  end

  def update
    @tax_credit = TaxCredit.find(params[:id])

    if @tax_credit.update_attributes(params[:tax_credit])
      flash[:notice] = "Kredit pajak berhasil diupdate"
    else
      flash[:notice] = "Kredit pajak gagal diupdate"
    end
    redirect_to accounting_tax_credits_path
  end

  def destroy
    @tax_credit = TaxCredit.find(params[:id])

    respond_to do |format|
      if @tax_credit.destroy
        flash[:notice] = 'Kredit pajak berhasil dihapus'
      end
        format.html { redirect_to(accounting_tax_credits_path) }
    end
  end

  def auto_complete_for_vendor_name
    search = params[:vendor][:name]
    vendors = Vendor.find(:all, :conditions => ["name LIKE ?", "%#{search}%"])
    render :partial => "shared/autocomplete_vendor", :locals => {:vendors => vendors}
  end

  def auto_complete_for_customer_name
    search = params[:customer][:name]
    customers = Customer.find(:all, :conditions => ["name LIKE ?", "%#{search}%"])
    render :partial => "shared/autocomplete_customer", :locals => {:customers => customers}
  end


  private
  def initial_method
    @title = "Kredit Pajak"
    @periode = true
  end
end
